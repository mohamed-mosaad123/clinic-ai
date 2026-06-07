# Stage 1: Build the Flutter Web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency files first for caching
COPY pubspec.yaml pubspec.lock ./

# Fetch pub packages
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build for web in release mode
RUN flutter build web --release

# Stage 2: Serve using Nginx
FROM nginx:alpine

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
