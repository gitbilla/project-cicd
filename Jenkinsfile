pipeline {
agent any

environment {
    GIT_REPO    = 'https://github.com/gitbilla/project-cicd.git'
    GIT_BRANCH  = 'main'

    IMAGE_NAME  = 'abramdocker/hello-flask'
    IMAGE_TAG   = "${BUILD_NUMBER}"
    DOCKER_REPO = 'abramdocker/hello-flask'
}

stages {

    stage('Checkout Source') {
        steps {
            git branch: "${GIT_BRANCH}",
                url: "${GIT_REPO}"
        }
    }

    stage('Build Docker Image') {
        steps {
            sh '''
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
            '''
        }
    }

    stage('Run Container Test') {
        steps {
            sh '''
                docker rm -f hello-flask-test || true

                docker run -d \
                  --name hello-flask-test \
                  -p 5000:5000 \
                  ${IMAGE_NAME}:${IMAGE_TAG}

                sleep 10

                curl -f http://localhost:5000

                docker rm -f hello-flask-test || true
            '''
        }
    }

    stage('Docker Push') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'DOCKER_CREDS',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )
            ]) {
                sh '''
                    echo "$DOCKER_PASS" | docker login \
                      -u "$DOCKER_USER" \
                      --password-stdin

                    docker push ${DOCKER_REPO}:${IMAGE_TAG}
                    docker push ${DOCKER_REPO}:latest
                '''
            }
        }
    }

    #stage('Deploy to Kubernetes') {
    #    steps {
    #        sh '''
    #            kubectl apply -f k8s/deployment.yaml
    #            kubectl apply -f k8s/service.yaml
    #
    #            kubectl set image deployment/hello-flask \
    #              hello-flask=abramdocker/hello-flask:${BUILD_NUMBER}
    #
    #            kubectl rollout status deployment/hello-flask
    #        '''
    #    }
    #}
}

post {
    success {
        echo 'Docker image built, pushed, and deployed successfully.'
    }

    failure {
        echo 'Build failed.'
    }

    always {
        sh '''
            docker image prune -f || true
        '''
    }
 }
}

