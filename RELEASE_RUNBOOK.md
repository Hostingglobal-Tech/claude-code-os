# Release runbook

이 저장소에서 GitHub Release를 만들 때는 `GITHUB_TOKEN` 환경변수를 그대로 쓰지 않는다.

## 이유

현재 WSL 환경의 활성 `GITHUB_TOKEN`은 fine-grained 토큰이며, GitHub Release API와 asset upload 권한이 부족할 수 있다. 이 토큰으로 `gh release create`를 실행하면 다음 오류가 난다.

```text
HTTP 403: Resource not accessible by personal access token
```

반면 `gh auth status`에 저장된 OAuth 토큰은 `repo` scope가 있어 Release 생성과 asset upload에 사용할 수 있다.

## 기본 명령 패턴

Release 작업은 항상 환경 토큰을 제거하고 실행한다.

```bash
env -u GITHUB_TOKEN -u GH_TOKEN gh release create ...
env -u GITHUB_TOKEN -u GH_TOKEN gh release upload ...
env -u GITHUB_TOKEN -u GH_TOKEN gh release view ...
```

## v2.0.6 asset 예시

```bash
cd /mnt/d/AICODE_OS_RELEASE/v2.0.6-build

env -u GITHUB_TOKEN -u GH_TOKEN gh release create v2.0.6 \
  --repo Hostingglobal-Tech/claude-code-os \
  --target main \
  --title 'v2.0.6 - AICODE-OS Caps Lock 한영 + USB 자동 준비 도구' \
  aicode-os-v2.0.6.iso.part1 \
  aicode-os-v2.0.6.iso.part2 \
  aicode-os-v2.0.6.iso.sha256 \
  cco-persistence.dat.xz \
  AICODE-OS-USB-자동설치도구-v2.0.6.zip
```

## 검증

```bash
env -u GITHUB_TOKEN -u GH_TOKEN gh release view v2.0.6 --repo Hostingglobal-Tech/claude-code-os
```
