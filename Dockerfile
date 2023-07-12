# BUILD Phase 
#   Use node:alpine, copy package.json, install dependencies, execute npm run build to build the app 
#   The goal is to create the assets in the build directory 

# Tag the base image as 'builder' so that you can just refer to it as the tag 
FROM node:16-alpine as builder 

WORKDIR '/app'

# Copy package.json to the WORKDIR of '/app'
COPY package.json . 

RUN npm install

# Copy over all the source code from local project to container 
# Important:
#   Remember that we are in the BUILD PHASE, i.e., not in the DEVELOPMENT PHASE 
#     Therefore, we are no longer changing our source code (that has been finalized in the DEV PHASE)
#       So, we no longer need Volumes to capture changes in real-time 
COPY . .

# Note that the build folder is going to be created in the working directory 
# The folder with all the production assets to be served up to the requestor, 
#   its path in the Container is '/app/build'
#     This is the folder that we want to copy over during the RUN Phase 
RUN npm run build

# =================================================================================================
# Run Phase 
#   Use nginx as base, copy over the final build from the BUILD Phase, start up nginx 

# Note that we dont need to explicitly end the previous configuration block 
FROM nginx

# Copy over the build folder into this nginx container 
# Copy from a difference phase, here that phase is "builder", so we're copying from the BUILD Phase 
# "/app/build" 
#     Refers to the folder that we want to copy 
#     We just want the assets in the "build" directory 
# "/usr/share/nginx/html" 
#   nginx container 
#   Documentation: https://hub.docker.com/_/nginx
#   Anything inside this html folder will be automatically served up by nginx when it starts up 
COPY --from=builder /app/build /usr/share/nginx/html

# The default command of the nginx image is going to start up nginx for us 
#   Meaning that we don't have to explicitly run anything to start up nginx 
