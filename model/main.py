import pandas as pd
import numpy as np
import os
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.models import Model

# Поточна директорія скрипта та шлях до папки
current_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(current_dir, '..', 'ham10000', 'HAM10000_metadata.csv')

# Завантаження датасету
skin_df = pd.read_csv(csv_path)

# Передобробка даних
# Унікальні класи та створення мапінгу
classes = skin_df['dx'].unique()
print("Класи:", classes)

# class_to_idx — це словник аби замінити назву класу діагнозу на індекс
class_to_idx = {name: idx for idx, name in enumerate(classes)}
print("Індекси класів:", class_to_idx)

# Передобробка даних

# Змінні для шляхів к двум папкам
images_path_1 = os.path.join(current_dir, '..', 'ham10000', 'HAM10000_images_part_1')
images_path_2 = os.path.join(current_dir, '..', 'ham10000', 'HAM10000_images_part_2')

# Функція пошуку в двох папках
def find_image_path(image_id):
    path1 = os.path.join(images_path_1, f"{image_id}.jpg")
    path2 = os.path.join(images_path_2, f"{image_id}.jpg")
    if os.path.exists(path1):
        return path1
    elif os.path.exists(path2):
        return path2
    else:
        return None  # Якщо зображення не знайдено

# Застосовуємо функцію до датафрейму, аби до кожного зображення був свій шлях
skin_df['path'] = skin_df['image_id'].apply(find_image_path)

# Видаляємо рядки без знайдених шляхів
skin_df = skin_df.dropna(subset=['path'])
# Мапимо діагноз на індекс
skin_df['label'] = skin_df['dx'].map(class_to_idx)
# Перетворюємо числові індекси у рядки. Це потрібно тому, що деякі функції flow_from_dataframe
# очікують, що мітки (y_col) будуть рядковими (string), а не числами.
skin_df['label'] = skin_df['label'].astype(str)


# Створення генератора даних

# Розмір зображень (ResNet50 приймає 224x224)
IMG_SIZE = 224
BATCH_SIZE = 32

# Функція для завантаження та збільшення зображень
datagen = keras.preprocessing.image.ImageDataGenerator(
    validation_split=0.2,  # 20% даних піде на валідацію
    rescale=1./255,         # Нормалізація: пікселі від 0 до 1
    horizontal_flip=True,   # Горизонтальне віддзеркалення
    zoom_range=0.2,         # Збільшення (zoom_range=0.2)
    rotation_range=20       # Обертання (rotation_range=20 градусів).
)


# Генератор для тренування
train_generator = datagen.flow_from_dataframe(
    dataframe=skin_df,
    x_col='path',
    y_col='label',
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='sparse',
    subset='training',
    shuffle=True
)

# Генератор для валідації
val_generator = datagen.flow_from_dataframe(
    dataframe=skin_df,
    x_col='path',
    y_col='label',
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='sparse',
    subset='validation',
    shuffle=True
)

# Завантаження базової моделі ResNet50

# Беремо попередньо натреновану ResNet50 без верхніх шарів (include_top=False)
base_model = ResNet50(
    weights='imagenet',    # Завантажуємо ваги, натреновані на ImageNet
    input_shape=(IMG_SIZE, IMG_SIZE, 3),
    include_top=False      # Не використовуємо останній шар класифікації
)

# Заморожуємо ВСІ шари, щоб спочатку навчати тільки "голову"
base_model.trainable = False

# Створюємо власну модель

# Новий верхній блок нейромережі
inputs = keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
x = base_model(inputs, training=False)  # НЕ тренуємо base_model поки що
x = layers.GlobalAveragePooling2D()(x)  # Спрощуємо вихід
x = layers.Dropout(0.5)(x)              # Додаємо dropout для захисту від перенавчання
outputs = layers.Dense(len(classes), activation='softmax')(x)  # Класифікатор

model = Model(inputs, outputs)

# Компіляція моделі

model.compile(
    optimizer=keras.optimizers.Adam(),
    loss='sparse_categorical_crossentropy',  # Класифікація за індексами класів
    metrics=['accuracy']
)

# Навчаємо верхню частину моделі

history = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=5  # Можна почати з 5
)

# Тюнінг: розморожуємо частину базової моделі

base_model.trainable = True

# Щоб не "зламати" ваги, використовуємо ДУЖЕ маленький крок навчання
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=1e-5),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Продовжуємо навчання всієї мережі
history_finetune = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=5  # Можна ще 5
)

# Зберігаємо модель

model_dir = os.path.join(current_dir, '..', 'model')  
os.makedirs(model_dir, exist_ok=True) 
model_path = os.path.join(model_dir, 'skin_disease_model.h5')
model.save(model_path)
print("Model saved to:", model_path)