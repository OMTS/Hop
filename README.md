# Running tests locally
When writting features or tests it is always a good idea to run tests locally before pushing code to github and triggering CI.

## Using Xcode
Just select Hop iOS scheme and execute **Cmd + U**

## Testing on Mac in a Linux environnement
Running tests on linux locally on your mac is very straightforward.
Hop is provided with a Dockerfile for this
In the same directory as the Dockerfile run:  

```
docker build . 
```
This will build the docker image to run and prompt the image name => "Successfully built **_{imageName}_**"

Run the image

```
docker run {imageName}
```
