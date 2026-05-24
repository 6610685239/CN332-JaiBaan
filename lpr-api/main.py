from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from inference_sdk import InferenceHTTPClient
import easyocr
import numpy as np
import cv2
from PIL import Image
import io
import re
import base64

app = FastAPI(title="JaiBaan LPR API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

import os
API_KEY = os.environ.get("ROBOFLOW_API_KEY")
if not API_KEY:
    print("❌ WARNING: ROBOFLOW_API_KEY not found in environment variables!")
MODEL_ID = "license-plate-recognition-rxg4e/4"

print("Connecting to Roboflow local server...")
client = InferenceHTTPClient(
    api_url="http://127.0.0.1:9001",
    api_key=API_KEY,
)

print("Loading EasyOCR (Thai + English)...")
reader = easyocr.Reader(['th', 'en'], gpu=True)

print("LPR API ready.")


def clean_plate_text(texts: list) -> str:
    combined = " ".join(texts).strip()
    combined = re.sub(r'[^\u0E00-\u0E7Fa-zA-Z0-9\s]', '', combined)
    combined = re.sub(r'\s+', ' ', combined).strip()
    return combined.upper()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/detect-plate")
async def detect_plate(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    img_np = np.array(image)

    # Step 1: Roboflow detects plate bounding boxes
    img_b64 = base64.b64encode(contents).decode("utf-8")
    result = client.infer(img_b64, model_id=MODEL_ID)

    predictions = result.get("predictions", [])

    if not predictions:
        # fallback: run OCR on full image
        ocr_results = reader.readtext(img_np)
        texts = [t for (_, t, c) in ocr_results if c > 0.3]
        plate = clean_plate_text(texts)
        return {
            "success": bool(plate),
            "plate": plate or None,
            "confidence": 0.0,
            "message": "No plate region detected, ran OCR on full image",
        }

    # Step 2: crop each detected plate region, run EasyOCR
    best_plate = ""
    best_conf = 0.0

    for pred in predictions:
        x, y, w, h = pred["x"], pred["y"], pred["width"], pred["height"]
        x1 = max(0, int(x - w / 2) - 5)
        y1 = max(0, int(y - h / 2) - 5)
        x2 = min(img_np.shape[1], int(x + w / 2) + 5)
        y2 = min(img_np.shape[0], int(y + h / 2) + 5)

        crop = img_np[y1:y2, x1:x2]
        if crop.size == 0:
            continue

        # Preprocess for better OCR
        gray = cv2.cvtColor(crop, cv2.COLOR_RGB2GRAY)
        resized = cv2.resize(gray, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
        _, thresh = cv2.threshold(resized, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

        ocr_results = reader.readtext(thresh)
        if not ocr_results:
            ocr_results = reader.readtext(crop)

        texts = [t for (_, t, c) in ocr_results if c > 0.3]
        plate_text = clean_plate_text(texts)
        detection_conf = pred.get("confidence", 0.0)

        if plate_text and detection_conf > best_conf:
            best_plate = plate_text
            best_conf = detection_conf

    if best_plate:
        return {
            "success": True,
            "plate": best_plate,
            "confidence": round(best_conf, 2),
        }
    else:
        return {
            "success": False,
            "plate": None,
            "confidence": 0.0,
            "message": "Plate region found but OCR failed",
        }
