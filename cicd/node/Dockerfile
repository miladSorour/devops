# Use an appropriate base image. For a production-ready environment, consider using an nginx image.
FROM nginx:alpine

RUN rm /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

# Copy your application's build artifacts from the artifacts stage to the nginx public directory
COPY ./build /usr/share/nginx/html

# Expose the port that nginx runs on
EXPOSE 80

# Start nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
