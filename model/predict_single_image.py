import os
import json
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image

# Шляхи
current_dir = os.path.dirname(os.path.abspath(__file__))
model_path = os.path.join(current_dir, '..', 'model', 'skin_model.h5')
class_indices_path = os.path.join(current_dir, '..', 'model', 'class_indices.json')

# Завантаження моделі
print("✅ Завантаження моделі...")
model = load_model(model_path)

# Завантаження мапінгу класів
with open(class_indices_path, 'r') as f:
    class_to_idx = json.load(f)

idx_to_class = {int(v): k for k, v in class_to_idx.items()}
print("✅ Класи:", list(idx_to_class.values()))

def predict_image(img_path):
    # Завантаження зображення
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = img_array / 255.0

    # Прогноз
    predictions = model.predict(img_array)
    predicted_index = np.argmax(predictions[0])
    predicted_class = idx_to_class[predicted_index]
    confidence = predictions[0][predicted_index]

    print(f"🔍 Прогноз: {predicted_class} (індекс: {predicted_index}) з довірою {confidence:.2f}")

# Тестовий виклик
if __name__ == "__main__":
    img_path = os.path.join(current_dir, '..', 'test_images', 'test_image.jpg')
    predict_image(img_path)
