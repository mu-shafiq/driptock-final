import tensorflow as tf

# Replace with the path where `saved_model.pb` is located
saved_model_dir = "C:\Users\Administrator\Downloads\arbitrary-image-stylization-v1-tensorflow1-256-v2"

# Load the model and create a TFLite converter
converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)

# Optimize for size and performance (optional)
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]

# Convert the model to TFLite
tflite_model = converter.convert()

# Save the converted model
output_path = "arbitrary_image_stylization.tflite"
with open(output_path, "wb") as f:
    f.write(tflite_model)

print(f"Model successfully converted and saved to {output_path}")
