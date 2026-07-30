FROM python:3.13-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --upgrade pip setuptools wheel
RUN pip install --prefix=/install -r requirements.txt

COPY . .

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app .

CMD ["python","app.py"]
