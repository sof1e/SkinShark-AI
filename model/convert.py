import tensorflow as tf

# Загружаем модель
model = tf.keras.models.load_model("model/model.h5")

# Конвертируем в TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Сохраняем
with open("model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Модель успешно конвертирована в model.tflite")
