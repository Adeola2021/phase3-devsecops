FROM python:3.13-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --upgrade pip
RUN pip install setuptools>=83.0.0 wheel

RUN pip install --upgrade pip setuptools wheel
RUN pip install --prefix=/usr/local -r requirements.txt

COPY . .

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

COPY --from=builder /usr/local /usr/local
COPY --from=builder /app .

# Override Chainguard's default entrypoint
ENTRYPOINT ["/usr/local/bin/python"]
CMD ["app.py"]
