resource "docker_image" "lms-fe-build" {
  name = "lms-fe"
  build {
    context = "."
    tag     = ["ravi2krishna/lms-fe:tf"]
    label = {
      author : "ravi"
    }
  }
}

# Create a container
resource "docker_container" "lms-fe-container" {
  image = docker_image.lms-fe-build.image_id
  name  = "lms-fe-container"
    ports {
    internal = 80
    external = 80
    ip       = "0.0.0.0"
  }
}