FROM rocketchat/rocket.chat:0.59.2

ENV MONGO_URL mongodb://devops-rocketchatdb:27017/rocketchat

VOLUME /app/uploads
