FROM openjdk:17
ADD SpringApp-0.0.1-SNAPSHOT.jar spring-eks.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "spring-eks.jar"]