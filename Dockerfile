FROM node:alpine
WORKDIR usr/app
COPY package*.json .
RUN npm install
COPY . .
RUN npm run build
CMD ["npm", "run", "start:prod"]

# COMMANDS:
# docker build -t acosta-rep-backend:1.0.0 .
# docker run -d -p 3000:3000 -v ./src/KEEP_TRACK:/usr/app/src/KEEP_TRACK/:rw acosta-rep-backend:1.0.0
# docker ps
# docker exec -it <container_name> /bin/sh