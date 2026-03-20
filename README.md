# 🦈 SkinShark-AI

**SkinShark-AI** is a cross-platform mobile application built with Flutter that uses convolutional neural networks to analyze skin conditions from images.

It allows users to upload or capture photos of their skin and receive fast, AI-powered insights into potential dermatological issues.

---

## ✨ Features

- 📸 Capture or upload skin images  
- 🤖 AI-powered skin condition detection  
- 🧠 Supports detection of:
  - Melanocytic Nevi
  - Melanoma
  - Benign Keratosis-like Lesions
  - Basal Cell Carcinoma
  - Actinic Keratoses
  - Vascular Lesions
  - Dermatofibroma
- 📊 Quick diagnostic feedback  
- 💡 Preventive care suggestions  
- 📚 Treatment and skincare resources  
- 🧾 History of previous scans  

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)  
- **Machine Learning:** TensorFlow Lite / PyTorch  
- **Model Architecture:** ResNet50 (trained on HAM10000 dataset)  

---

## 🚀 How It Works

1. User captures or uploads an image  
2. Image is processed and passed to the ML model  
3. The model classifies the skin condition  
4. The app displays:
   - Predicted condition  
   - Confidence score  
   - Basic recommendations  

---

## ⚠️ Disclaimer

SkinShark-AI is designed for **educational and informational purposes only**.  
It is **not a medical diagnosis tool** and should not replace professional medical advice.

---

## 🔧 Installation

```bash
git clone https://github.com/your-username/SkinShark-AI.git
cd SkinShark-AI
flutter pub get
flutter run
```

---

## 📈 Future Improvements

- 🔍 More skin condition classes  
- ☁️ Cloud-based model inference  
- 🧬 Explainability (Grad-CAM visualization)  
- 👤 User profiles and progress tracking  
- 🌍 Multi-language support  

---

## 👩‍💻 Author

Developed by Sofiia Honcharova  

---

## ⭐ Why This Project Matters

SkinShark-AI demonstrates the integration of:
- Mobile development  
- Machine learning  
- Real-world healthcare applications  

It highlights how AI can be used for early detection and awareness, making skincare more accessible.
