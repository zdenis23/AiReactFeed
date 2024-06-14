# syntax=docker/dockerfile:1

FROM python:3.11.9-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install basic packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends lsb-release curl gpg nano netcat-traditional

# Install redis
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends redis

# Install pip python packages
COPY requirements.txt /rss_ai/requirements.txt
RUN pip3 install --no-cache-dir -r /rss_ai/requirements.txt

# Add non-root user "app_user"
RUN useradd -U app_user \
    && install -d -m 0755 -o app_user -g app_user /rss_ai
USER app_user:app_user

# Copy code and make dir editable by "app_user"
COPY --chown=app_user:app_user / /rss_ai/

WORKDIR /rss_ai

RUN chown -R app_user:app_user /rss_ai \
    && chmod 755 /rss_ai

# Add docker container labels
LABEL org.opencontainers.image.title="AI News Plattform"
LABEL org.opencontainers.image.description="News Aggregator"
LABEL org.opencontainers.image.authors="https://react.com"
LABEL org.opencontainers.image.url="https://react.com"
LABEL org.opencontainers.image.documentation="https://react.com"
LABEL org.opencontainers.image.source="https://react.com"
LABEL org.opencontainers.image.licenses="MIT"

# Expose Port: Main website
EXPOSE 80
# Expose Port: Celery Flower - for dev
EXPOSE 5555
# Expose Port: Supervisord - for dev
EXPOSE 9001
# Permanent storage for databse and config files
VOLUME /rss_ai/data

# Configure automatic docker conatiner healthcheck
HEALTHCHECK --interval=5m --timeout=60s --retries=3 --start-period=120s \
    CMD echo Successful Docker Container Healthcheck && curl --max-time 30 --connect-timeout 30 --silent --output /dev/null --show-error --fail http://localhost:80/ || exit 1

# Start News Platform using supervisord
CMD ["supervisord", "-c", "./supervisord.conf"]
