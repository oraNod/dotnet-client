#!/usr/bin/env groovy

pipeline {
    agent any
    
    environment {
      HOTROD_LOG_LEVEL = 'TRACE'
      INFINISPAN_VERSION = '9.0.0.Final'
      JAVA_HOME = '/opt/oracle-jdk8'
      JBOSS_HOME = '/home/ec2-user/ispn/infinispan-server'
      M2_HOME = '/opt/maven'
    }
    
    stages {
        stage('Cleanup') {
            steps{
                step([$class: 'WsCleanup'])
            }
        }
    
        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    sh "echo ./build.bat"
                }
            }
        }
    }
}
