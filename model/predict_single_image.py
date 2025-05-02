import os
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.resnet50 import preprocess_input
import pandas as pd

# Шлях до зображення для тесту
current_dir = os.path.dirname(os.path.abspath(__file__))
img_path = os.path.join(current_dir, '..', 'test_images', 'test_image.jpg')

# Перевірка наявності зображення
if not os.path.exists(img_path):
    print(f"Зображення не знайдено за шляхом: {img_path}")
    exit()

# Завантаження моделі
model_path = os.path.join(current_dir, 'skin_disease_model.h5')
if not os.path.exists(model_path):
    print(f"Модель не знайдена за шляхом: {model_path}")
    exit()

model = load_model(model_path)
print("Модель завантажено.")

# Завантаження метаданих для класів (щоб отримати назву по індексу)
csv_path = os.path.join(current_dir, '..', 'ham10000', 'HAM10000_metadata.csv')
df = pd.read_csv(csv_path)
class_names = sorted(df['dx'].unique())  # список назв класів, відсортований за індексами
print("Класи:", class_names)

# Передобробка зображення
img = image.load_img(img_path, target_size=(224, 224))
x = image.img_to_array(img)
x = np.expand_dims(x, axis=0)
x = preprocess_input(x)

# Прогноз
preds = model.predict(x)
predicted_class_index = np.argmax(preds[0])
confidence = np.max(preds[0])
predicted_class_name = class_names[predicted_class_index]

# Результат
print(f"Прогноз: {predicted_class_name} (індекс: {predicted_class_index}) з довірою {confidence:.2f}")
