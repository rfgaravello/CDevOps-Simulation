FROM python:3.10-slim

# Criar usuário não-root (Boa prática crucial para segurança hospitalar/Philips)
RUN useradd -m devopsuser
WORKDIR /home/devopsuser/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
RUN chown -R devopsuser:devopsuser /home/devopsuser/app

USER devopsuser

EXPOSE 8080

CMD ["python", "app.py"]