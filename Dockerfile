FROM node:alpine
WORKDIR usr/app
COPY package*.json .
RUN npm install
RUN echo "Remember to have an .env file, or else you'll get an error."
COPY . .
RUN npm run build
CMD ["npm", "run", "start:prod"]