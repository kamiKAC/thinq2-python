pipeline {
    agent any
    environment {
        registry = "kamikac/thinq2-mqtt"
        platforms = "linux/arm/v7,linux/arm/v6,linux/amd64"
    }
    stages {
/*        stage('Docker build') {
             steps {
                script {
                    customImage = docker.build("app-image:${env.BUILD_ID}")
                }
            }
        }
        stage('Docker - app full test') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'state_json', variable: 'STATE_JSON')]) {
                        dir('state') {
                            docker.image('clipse-mosquitto:2.0.15-openssl').withRun("--name mosquitto -p 1883:1883")
                            container = customImage.withRun("--link mosquitto:mosquitto -v $PWD:/thinq2-python/state -e DB_HOST=mosquitto") {}
                        }
                    }
                }
            }
        }
        stage('Docker - app external test') {
            steps {
                script {
                    container = customImage.run('-p 8080:8080','node app.js') 
                }
                sh 'sleep 10'
                sh 'wget -O- $(hostname):8080'
            }
        }
        stage('Docker - send image to DockerHub') {
            steps {
                script {
                    withRegistry("https://docker.io/",'dockerhub')
                    customImage.Image.push("app-image:${env.BUILD_ID}")
                }
            }
        }
*/
        stage('Docker - Check / enable multiarch support') {
            steps {
                script {
                    def status = sh(returnStatus: true, script: 'cat /proc/sys/fs/binfmt_misc/qemu-aarch64|grep "enabled"')
                    if (status != 0) {
                        currentBuild.result = 'FAILED'
                        echo 'Multiarch not supported on node - use "sudo apt -y install qemu-user-static" to enable'
                        sh 'exit 1'
                    }
                }
                //Enable multiarch support - Driver 'docker-container'
                sh 'docker buildx inspect --bootstrap|grep -e "Driver:\\s*docker-container" || docker buildx create --use --name multiarch && docker buildx inspect --bootstrap'
            }
        }
        stage('Docker multiarch build and push') {
            environment {
                DOCKERHUB_CREDS = credentials('dockerhub')
            }
            steps {
                script {
                    sh "echo $DOCKERHUB_CREDS_PSW|docker login --username $DOCKERHUB_CREDS_USR --password-stdin \
                    && docker buildx build -t ${registry}:${env.BUILD_ID} --platform $platforms --push ."
                }
            }
        }
    }
    post {
        always {
/*            script {
                container.stop()
            }
            junit '*.xml' */
            echo 'Finished'
        }
    }
}
  
