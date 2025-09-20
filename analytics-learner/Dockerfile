# Analytics & Learner Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
COPY sample_signals/ ./sample_signals/
CMD ["pytest", "src/tests"]
