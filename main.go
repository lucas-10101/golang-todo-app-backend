package main

import "github.com/gin-gonic/gin"

func main() {

	engine := gin.New()

	engine.Group("/task")

}
