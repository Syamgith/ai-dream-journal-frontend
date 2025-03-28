# Use an official nginx image as base
FROM nginx:alpine

# Copy the built web files to nginx's web directory
COPY web /usr/share/nginx/html

# Optional: Copy a custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose a specific port (we'll use 3000 to avoid conflicts)
EXPOSE 3001

CMD ["nginx", "-g", "daemon off;"]