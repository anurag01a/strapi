FROM node:18-alpine

WORKDIR /opt/app

COPY package.json ./
COPY index.js ./

# No npm install needed - we use only built-in modules

EXPOSE 1337

CMD ["npm", "run", "start"]
