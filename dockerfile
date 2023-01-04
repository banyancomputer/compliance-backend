FROM node:17.3.0
ENV NODE_ENV=production

WORKDIR /app

COPY pyproject.toml .

RUN poetry install

COPY src ./src