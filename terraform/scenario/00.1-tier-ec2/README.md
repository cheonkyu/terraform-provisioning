# AWS ec2 서버 구성

1. SSM을 이용해서 터미널 접속
2. VPC를 구성하고 퍼블릭/프라이빗 서브넷을 구성한다. (인터넷게이트웨이, 라우팅테이블, NAT 인스턴스 구현)

## 네트워크 토폴리지

- VPC CIDR : 10.0.0.0/16

![1](https://github.com/int128/terraform-aws-nat-instance/raw/master/diagram.svg)

## 모듈

- vpc : [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- ec2 : [terraform-aws-modules/ec2](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)
- NAT인스턴스 : [int128/nat-instance/aws](https://github.com/int128/terraform-aws-nat-instance/tree/master?tab=readme-ov-file)
- 보안그룹(Security Group) : [terraform-aws-modules/security-group/aws](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)

## SSM 특징/장점

✅ 인바운드 포트를 열거나 SSH 키를 관리할 필요 없이 관리형 인스턴스에 안전하게 연결한다.
✅ Bastion host 나 Key pair 가 필요 없다.
✅ HTTPS 프로토콜을 사용하여 접속이 가능하다. (SSH가 아님)
✅ 선택한 목적 또는 활동에 따라 AWS 리소스를 그룹화하여 중앙 집중식 관리가 가능하다.

### 세션관리자 bash쉘로 열기

AWS Systems Manager >> 세션 관리자 >> 기본 설정 >> Shell profiles >> Linux shell profile

![2](https://blog.kakaocdn.net/dn/cVgYWw/btrJ70pm8kc/qoKDmlZEDGDsfVsQl8jWuk/img.png)
