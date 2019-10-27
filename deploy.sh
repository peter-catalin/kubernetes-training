# We first need to build and tag all our images. As you can see we create two tags for each image: the latest and a tag that contains 
# the GIT SHA of the latest commit. This allows us to change the image used by our containers in the last part of the file. If we were to
# set the latest image with the kubectl set image that would not work because internally Kubernetes thinks it is already running the lastest image.
# By using a unique identifier for our image we gracefully solve that problem.
docker build -t petercatalin/docker-training-multi-client:latest -t petercatalin/docker-training-multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t petercatalin/docker-training-multi-server:latest -t petercatalin/docker-training-multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t petercatalin/docker-training-multi-worker -t petercatalin/docker-training-multi-worker:$SHA -f ./worker/Dockerfile ./worker

# Once the images are successfully generated we need to push them to DockerHub.
docker push petercatalin/docker-training-multi-client:latest
docker push petercatalin/docker-training-multi-server:latest
docker push petercatalin/docker-training-multi-worker:latest
docker push petercatalin/docker-training-multi-client:$SHA
docker push petercatalin/docker-training-multi-server:$SHA
docker push petercatalin/docker-training-multi-worker:$SHA

# After the images are pushed we ask Travis to apply all our configuration files located in the k8s directory
# in order to update our cluster as needed.
kubectl apply -f k8s

# Once the cluster is updated, we imperatively change the images used by the deployments to the latest one, using the SHA tag
# and therefore forcing Kubernetes to perform the update.
kubectl set image deployments/server-deployment server=petercatalin/docker-training-multi-server:$SHA
kubectl set image deployments/client-deployment client=petercatalin/docker-training-multi-client:$SHA
kubectl set image deployments/worker-deployment worker=petercatalin/docker-training-multi-worker:$SHA