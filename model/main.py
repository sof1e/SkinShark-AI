import pandas as pd
import numpy as np
import os
import json
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.models import Model

# Шляхи
current_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(current_dir, '..', 'ham10000', 'HAM10000_metadata.csv')
images_path_1 = os.path.join(current_dir, '..', 'ham10000', 'HAM10000_images_part_1')
images_path_2 = os.path.join(current_dir, '..', 'ham10000', 'HAM10000_images_part_2')
model_dir = os.path.join(current_dir, '..', 'model')
os.makedirs(model_dir, exist_ok=True)

# Завантаження датасету
skin_df = pd.read_csv(csv_path)

# Унікальні класи та мапінг
classes = sorted(skin_df['dx'].unique())  # відсортувати для консистентності
print("Класи:", classes)

class_to_idx = {name: idx for idx, name in enumerate(classes)}
print("Індекси класів:", class_to_idx)

# Збереження мапінгу до JSON
class_indices_path = os.path.join(model_dir, 'class_indices.json')
with open(class_indices_path, 'w') as f:
    json.dump(class_to_idx, f)

# Пошук шляхів до зображень
def find_image_path(image_id):
    path1 = os.path.join(images_path_1, f"{image_id}.jpg")
    path2 = os.path.join(images_path_2, f"{image_id}.jpg")
    if os.path.exists(path1):
        return path1
    elif os.path.exists(path2):
        return path2
    else:
        return None

skin_df['path'] = skin_df['image_id'].apply(find_image_path)
skin_df = skin_df.dropna(subset=['path'])
skin_df['label'] = skin_df['dx'].map(class_to_idx).astype(str)

# Генератори
IMG_SIZE = 224
BATCH_SIZE = 32

datagen = keras.preprocessing.image.ImageDataGenerator(
    validation_split=0.2,
    rescale=1./255,
    horizontal_flip=True,
    zoom_range=0.2,
    rotation_range=20
)

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

# Створення моделі
base_model = ResNet50(
    weights='imagenet',
    input_shape=(IMG_SIZE, IMG_SIZE, 3),
    include_top=False
)
base_model.trainable = False

inputs = keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
x = base_model(inputs, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.5)(x)
outputs = layers.Dense(len(classes), activation='softmax')(x)
model = Model(inputs, outputs)

model.compile(
    optimizer=keras.optimizers.Adam(),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Навчання верхньої частини
history = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=5
)

# Fine-tuning
base_model.trainable = True
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=1e-5),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

history_finetune = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=5
)

# Збереження моделі
model_path = os.path.join(model_dir, 'skin_model.h5')
model.save(model_path)
print("✅ Модель збережено до:", model_path)
