# 프론트엔드 배포 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **DevOps 엔지니어**: 프론트엔드 배포 파이프라인을 구축하고 관리하는 담당자
* **프론트엔드 개발자**: 배포 프로세스를 이해하고 문제 발생 시 대응하는 담당자
* **인프라 관리자**: S3와 CloudFront를 관리하는 책임자

---

## 핵심 요약 (Executive Summary)

본 문서는 dialogym 프론트엔드 애플리케이션의 배포 절차를 정의합니다.
프론트엔드는 React 애플리케이션을 Vite로 빌드하여 정적 파일을 생성합니다.
S3 버킷에 정적 호스팅을 설정하고, CloudFront를 통해 CDN으로 제공합니다.
dev 브랜치는 Staging 환경, main 브랜치는 Production 환경으로 자동 배포됩니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [배포 환경](#배포-환경)
3. [React 빌드](#react-빌드)
4. [S3 설정](#s3-설정)
5. [CloudFront 설정](#cloudfront-설정)
6. [도메인 연결](#도메인-연결)
7. [GitHub Actions 워크플로우](#github-actions-워크플로우)
8. [배포 확인](#배포-확인)

---

## 문서 개요 (Overview)

본 문서는 프론트엔드 배포 프로세스를 명확히 하기 위해 작성되었습니다.

프론트엔드는 정적 파일로 빌드되므로 S3 정적 호스팅과 CloudFront CDN을 활용하여 빠르고 안정적으로 제공합니다. Docker나 Kubernetes 없이 AWS 서비스만으로 배포합니다.

---

## 배포 환경

### Staging 환경

```yaml
브랜치: dev
S3 버킷: dialogym-frontend-staging
CloudFront: staging.dialogym.com
API 엔드포인트: https://api-staging.dialogym.com
```

### Production 환경

```yaml
브랜치: main
S3 버킷: dialogym-frontend-production
CloudFront: dialogym.com, www.dialogym.com
API 엔드포인트: https://api.dialogym.com
```

---

## React 빌드

### 환경 변수 설정

`frontend/.env.production`:

```bash
VITE_API_URL=https://api.dialogym.com
VITE_APP_NAME=dialogym
VITE_APP_VERSION=1.0.0
```

`frontend/.env.staging`:

```bash
VITE_API_URL=https://api-staging.dialogym.com
VITE_APP_NAME=dialogym-staging
VITE_APP_VERSION=1.0.0-staging
```

### package.json 스크립트

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "build:staging": "vite build --mode staging",
    "build:production": "vite build --mode production",
    "preview": "vite preview"
  }
}
```

### 로컬 빌드 테스트

```bash
cd frontend

# 의존성 설치
npm ci

# Staging 빌드
npm run build:staging

# Production 빌드
npm run build:production

# 빌드 결과 확인
ls -lh dist/

# 로컬 미리보기
npm run preview
```

---

## S3 설정

### S3 버킷 생성

```bash
# Staging 버킷
aws s3 mb s3://dialogym-frontend-staging --region ap-northeast-2

# Production 버킷
aws s3 mb s3://dialogym-frontend-production --region ap-northeast-2
```

### 정적 웹사이트 호스팅 설정

```bash
# Staging 버킷 설정
aws s3 website s3://dialogym-frontend-staging \
  --index-document index.html \
  --error-document index.html

# Production 버킷 설정
aws s3 website s3://dialogym-frontend-production \
  --index-document index.html \
  --error-document index.html
```

### 버킷 정책 설정

`s3-bucket-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::dialogym-frontend-production/*"
    }
  ]
}
```

```bash
# 버킷 정책 적용
aws s3api put-bucket-policy \
  --bucket dialogym-frontend-production \
  --policy file://s3-bucket-policy.json
```

### 수동 업로드 (테스트용)

```bash
# 빌드 후 S3 동기화
npm run build:production

aws s3 sync dist/ s3://dialogym-frontend-production \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "index.html" \
  --exclude "*.html"

# HTML 파일은 캐시 방지
aws s3 sync dist/ s3://dialogym-frontend-production \
  --delete \
  --cache-control "no-cache, no-store, must-revalidate" \
  --exclude "*" \
  --include "*.html"
```

---

## CloudFront 설정

### CloudFront 배포 생성

```bash
# CloudFront 배포 설정 JSON
cat > cloudfront-config.json <<EOF
{
  "CallerReference": "dialogym-frontend-$(date +%s)",
  "Comment": "dialogym Frontend Distribution",
  "Enabled": true,
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-dialogym-frontend-production",
        "DomainName": "dialogym-frontend-production.s3-website.ap-northeast-2.amazonaws.com",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "http-only"
        }
      }
    ]
  },
  "DefaultRootObject": "index.html",
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-dialogym-frontend-production",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "Compress": true,
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000
  },
  "CustomErrorResponses": {
    "Quantity": 1,
    "Items": [
      {
        "ErrorCode": 404,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 300
      }
    ]
  },
  "PriceClass": "PriceClass_200"
}
EOF

# CloudFront 배포 생성
aws cloudfront create-distribution --distribution-config file://cloudfront-config.json
```

### CloudFront 캐시 무효화

```bash
# 캐시 무효화
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/*"

# 특정 파일만 무효화
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/index.html" "/assets/*"
```

---

## 도메인 연결

### SSL 인증서 발급 (ACM)

```bash
# us-east-1 리전에서 발급 필요 (CloudFront용)
aws acm request-certificate \
  --domain-name dialogym.com \
  --subject-alternative-names www.dialogym.com \
  --validation-method DNS \
  --region us-east-1
```

### Route 53 또는 가비아 DNS 설정

**Route 53 사용 시:**

```bash
# Hosted Zone 생성
aws route53 create-hosted-zone \
  --name dialogym.com \
  --caller-reference $(date +%s)

# A 레코드 생성 (CloudFront Alias)
cat > route53-record.json <<EOF
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "dialogym.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "d1234567890.cloudfront.net",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id <ZONE_ID> \
  --change-batch file://route53-record.json
```

**가비아 DNS 설정:**

```
가비아 DNS 관리 → dialogym.com

CNAME 레코드 추가:
- 호스트: www
- 값: d1234567890.cloudfront.net
- TTL: 600

A 레코드는 CloudFront IP를 직접 지정할 수 없으므로 CNAME 사용
루트 도메인(dialogym.com)은 가비아에서 CloudFront 직접 연결 불가
→ Route 53 사용 권장
```

---

## GitHub Actions 워크플로우

`.github/workflows/deploy-frontend.yml`:

```yaml
name: Deploy Frontend

on:
  push:
    branches: [dev, main]
    paths:
      - 'frontend/**'
      - '.github/workflows/deploy-frontend.yml'

env:
  AWS_REGION: ap-northeast-2

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: './frontend/package-lock.json'

      - name: Install dependencies
        run: npm ci
        working-directory: ./frontend

      - name: Set environment variables
        id: set-env
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "BUILD_MODE=production" >> $GITHUB_OUTPUT
            echo "S3_BUCKET=dialogym-frontend-production" >> $GITHUB_OUTPUT
            echo "CLOUDFRONT_ID=${{ secrets.CLOUDFRONT_PRODUCTION_ID }}" >> $GITHUB_OUTPUT
          else
            echo "BUILD_MODE=staging" >> $GITHUB_OUTPUT
            echo "S3_BUCKET=dialogym-frontend-staging" >> $GITHUB_OUTPUT
            echo "CLOUDFRONT_ID=${{ secrets.CLOUDFRONT_STAGING_ID }}" >> $GITHUB_OUTPUT
          fi

      - name: Build
        run: npm run build:${{ steps.set-env.outputs.BUILD_MODE }}
        working-directory: ./frontend

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Sync to S3
        run: |
          # 정적 자산 (캐시 활성화)
          aws s3 sync dist/ s3://${{ steps.set-env.outputs.S3_BUCKET }} \
            --delete \
            --cache-control "public, max-age=31536000, immutable" \
            --exclude "index.html" \
            --exclude "*.html"

          # HTML 파일 (캐시 비활성화)
          aws s3 sync dist/ s3://${{ steps.set-env.outputs.S3_BUCKET }} \
            --delete \
            --cache-control "no-cache, no-store, must-revalidate" \
            --exclude "*" \
            --include "*.html"
        working-directory: ./frontend

      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ steps.set-env.outputs.CLOUDFRONT_ID }} \
            --paths "/*"

      - name: Verify deployment
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            curl -f https://dialogym.com || exit 1
          else
            curl -f https://staging.dialogym.com || exit 1
          fi

      - name: Notify Slack
        if: always()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "${{ job.status == 'success' && '✅' || '❌' }} Frontend 배포 ${{ job.status }}: ${{ github.ref_name }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Frontend 배포*\n브랜치: `${{ github.ref_name }}`\n상태: ${{ job.status }}\n커밋: ${{ github.sha }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

---

## 배포 확인

### S3 확인

```bash
# 업로드된 파일 확인
aws s3 ls s3://dialogym-frontend-production/ --recursive

# 파일 개수 확인
aws s3 ls s3://dialogym-frontend-production/ --recursive | wc -l
```

### CloudFront 확인

```bash
# 배포 상태 확인
aws cloudfront get-distribution --id <DISTRIBUTION_ID> \
  --query 'Distribution.Status'

# 캐시 무효화 상태 확인
aws cloudfront list-invalidations --distribution-id <DISTRIBUTION_ID>
```

### 브라우저 테스트

```bash
# Staging
open https://staging.dialogym.com

# Production
open https://dialogym.com
open https://www.dialogym.com
```

### 성능 확인

```bash
# Lighthouse 실행
lighthouse https://dialogym.com \
  --output html \
  --output-path ./lighthouse-report.html

# CloudFront 헤더 확인
curl -I https://dialogym.com
```

---

## 관련 문서

* [CI/CD 통합](ci-cd-integration.md)
* [백엔드 배포](deployment-backend.md)
* [롤백 가이드](rollback-guide.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.07 | 왕택준 | 최초 작성 |
