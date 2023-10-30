pipeline {
    agent any
        parameters {
        booleanParam(name: "push_to_registry", defaultValue: true, description: "Should image be pushed to registry?")
        booleanParam(name: "add_latest_tag", defaultValue: true, description: "Should tag latest be added to pushed image?")
        string(name: "registry", defaultValue: "kamikac/thinq2-mqtt", trim: true, description: "Registry where images are pushed")
        string(name: "version", defaultValue: "0", trim: true, description: "Release version. If 0 build version is used")
        string(name: "platforms", defaultValue: "linux/arm/v7,linux/arm/v6,linux/amd64,linux/arm64", description: "Input comma separated platforms for build")
    }
    environment {
        image_build = "${params.version == "0" ? env.BUILD_ID : params.version}"
    }
    stages {
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
                    if (params.add_latest_tag.toBoolean()) {
                        env.docker_params = "-t ${params.registry}:latest"
                    }
                    else {
                        env.docker_params = ""
                    }
                    if (params.push_to_registry.toBoolean()) {
                        sh "echo $DOCKERHUB_CREDS_PSW|docker login --username $DOCKERHUB_CREDS_USR --password-stdin \
                        && docker buildx build -t ${params.registry}:${env.image_build} ${env.docker_params} --platform ${params.platforms} --push ."
                    }
                    else {
                        sh "docker buildx build -t ${params.registry}:${env.image_build} ${env.docker_params} --platform ${params.platforms} ."
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Finished'
        }
    }
}
  
