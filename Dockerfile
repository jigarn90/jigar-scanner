FROM node:20-alpine
  WORKDIR /app
  COPY dist/index.cjs ./dist/
  COPY public ./public
  ENV NODE_ENV=production
  ENV PORT=8080
  EXPOSE 8080
  CMD ["node", "dist/index.cjs"]
  