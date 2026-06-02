# 슬라이서 검증 가이드 (PLA·캐스터블 레진 출력 전)

## 빠른 체크 (5분)

### 1. 슬라이서에 STL 열기
- **PLA 출력 (시험용, FDM)**: Bambu Studio · Prusa Slicer · Cura
- **캐스터블 레진 출력 (주물용, SLA/DLP)**: Chitubox · Lychee Slicer · Bambu Studio (Bambu Lab A1/X1 + 레진 어댑터)

파일: `ESC_1u_flat_hollow_1.0mm_design.stl` (시험용) 또는 `_cast.stl` (수축 보정본)

### 2. 자동 점검할 항목
| 점검 | 정상 기준 | 문제 신호 |
|---|---|---|
| **Manifold (수밀성)** | "No errors" / 초록 체크 | "Non-manifold edges" 빨간 경고 → STL 손상 |
| **Wall thickness** | 1.0 mm 균일 | 0.4 mm 이하 영역 발견 시 강도 부족 경고 |
| **Inverted normals** | 없음 | 보라색/뒤집힌 면 있으면 STL 손상 |
| **Mesh repair** | "No repair needed" | "Auto-repair" 메시지 뜨면 우리 STL 문제 — 다시 export 필요 |

### 3. 출력 방향 (Orientation)
- **권장**: 바닥(MX 십자 슬롯)이 **위쪽**을 향하게 거꾸로 세움
  - 이유: 바닥이 개방형이라 서포트 거의 불필요, 윗면(ESC 각인)은 빌드 플레이트 쪽이라 매끈히 출력됨
- 측면 출력은 비추천 (사면이 모두 경사라 서포트 많이 필요)

### 4. 서포트 설정
- **FDM (PLA)**: 십자 슬롯 안쪽에 미세한 서포트 자동 생성될 수 있음. 출력 후 제거 가능
- **레진 (캐스터블)**: 외부 표면에만 가는 서포트 (0.4mm), 매끈한 면은 위쪽으로

### 5. 인쇄 설정 권장
**FDM 시험 출력 (PLA)**:
- Nozzle: 0.4 mm
- Layer: 0.16 mm
- Walls: 4 perimeters (실리콘 키캡과 흡사한 두께감)
- Infill: 25% (시험용이므로 가벼우면 됨)
- Time: ~30분 ~ 1시간 / cap

**캐스터블 레진 (주물 의뢰용)**:
- Layer: 0.05 mm (정밀)
- Resin: 캐스터블 (Castable wax-based) — Phrozen Wax Resin / Siraya Tech Cast
- 출력 후 burnout 가능한 잔여물 없는 종류
- Time: ~1시간 / cap

## 예상되는 경고 & 대응

| 경고 | 의미 | 대응 |
|---|---|---|
| "Wall under 0.5mm" | 일부 구간 wall thin | 우리 디자인은 0.7mm 최소 — 무시 OK |
| "Overhangs detected" | 일부 면이 45° 이상 경사 | 측면 경사 (top_inset 3mm) — 서포트 자동 처리 |
| "Multiple shells" | 분리된 메시 발견 | + stem의 4 pillar는 top wall로 연결되어 있음 — 정상 |
| "Mesh has gaps" | 진짜 STL 손상 | 우리 STL은 watertight 검증됨 — 다시 export |

## 확인 후 다음 단계

✓ 슬라이서 통과 → PLA 시험 출력 또는 캐스터블 레진 출력 의뢰
✗ 경고 떠도 무시 가능한 항목이면 진행, 아니면 keycap.scad에서 파라미터 조정 후 re-export
