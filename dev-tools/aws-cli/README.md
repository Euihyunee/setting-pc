# AWS CLI v2

AWS Command Line Interface 설치 + 자격 증명 설정 안내.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-aws-cli.ps1`](./install-aws-cli.ps1) | AWS CLI v2 설치 + 버전/자격증명 검증 |

## 설치

```powershell
./install-aws-cli.ps1
```

## 직접 설치

```powershell
winget install Amazon.AWSCLI

# 버전 확인
aws --version
```

## 자격 증명 설정

### IAM Access Key 방식
```powershell
aws configure
# AWS Access Key ID:     AKIAxxxxxxxxx
# AWS Secret Access Key: xxxxxxxxxxxxxxxxxxxxxxxxx
# Default region name:   ap-northeast-2
# Default output format: json
```

결과 파일:
- `%USERPROFILE%\.aws\credentials` — 키
- `%USERPROFILE%\.aws\config` — region / output

### SSO 방식 (조직 계정)
```powershell
aws configure sso
# Start URL: https://your-org.awsapps.com/start
# SSO Region: us-east-1
# 브라우저 인증 → 계정/Role 선택
```

### 여러 프로필 사용
```powershell
aws configure --profile work
aws configure --profile personal

# 사용
aws s3 ls --profile work
$env:AWS_PROFILE = "work"   # 현재 세션 기본 프로필 지정
```

## 자주 쓰는 명령

```powershell
# 현재 인증된 사용자 확인
aws sts get-caller-identity

# 프로필 목록
aws configure list-profiles

# S3
aws s3 ls
aws s3 cp file.txt s3://my-bucket/
aws s3 sync ./local s3://my-bucket/prefix/

# EC2
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# 로그 (CloudWatch)
aws logs tail /aws/lambda/my-function --follow
```

## 주의: 자격 증명 보안

- `~/.aws/credentials` 는 평문 키를 저장합니다. **절대 git에 커밋하지 마세요.**
- 가능하면 **SSO** 또는 **IAM Identity Center** 사용 권장 (단기 토큰)
- IAM User Key를 쓸 경우 권한 최소화 + 주기적 로테이션
