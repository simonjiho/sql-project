# 학사관리시스템 ERD 3-3단계: 모델 정제 후 엔티티·속성 정의

## 1. 문서 정보

| 항목 | 내용 |
|---|---|
| 단계 | 3-3단계: 정규화·비정규화 종합 검토 후 엔티티·속성 확정 |
| 기준 문서 | `erd-01-01-requirements.md` |
| 확정 결정 | `erd-01-03-requirements-response.md` |
| 선행 결과물 | `erd-02-to-03-entities-attributes.md` |
| 종합 검토 | `erd-03-01-normalization-review.md`, `erd-03-02-denormalization-review.md` |
| 작성일 | 2026-07-22 |
| 상태 | 모델 정제 반영 완료·결과물 검토 승인 대기 |

이 문서는 2·3단계 초안을 대상으로 정규화와 비정규화를 함께 검토한 뒤 확정한 엔티티·속성 기준 문서다. 관계 구현 방식과 카디널리티는 이 문서를 입력으로 4·5단계에서 정의한다.

## 2. 작업 원칙

### 2.1 엔티티 판단 기준

- 여러 건을 지속적으로 등록·변경·조회하는 업무 대상인가?
- 각 건을 다른 건과 구분해야 하는가?
- 자체적으로 보존할 업무 사실이 있는가?
- 다른 업무 대상과 연결되는가?
- 단순 상태값, 표시 문구 또는 계산 결과가 아닌가?
- 요구사항에서 제외한 업무를 새로 도입하지 않았는가?

### 2.2 속성 판단 기준

- 업무 수행과 조회에 필요한 정보만 저장한다.
- 내부 식별자, 업무 식별자, 참조 후보, 일반값과 파생값을 구분한다.
- 필수·선택·조건부 필수 여부와 허용값을 명시한다.
- 조회 시 계산할 수 있는 표시값은 원본과 중복 저장하지 않는다.
- 관계와 외래키는 아직 확정하지 않고 참조 속성 후보로만 표시한다.

## 3. 표기 기준

| 표기 | 의미 |
|---|---|
| PK | 엔티티 내부 대체 식별자 후보 |
| AK | 업무상 식별자 또는 유일값 후보 |
| REF | 다른 엔티티를 참조할 속성 후보. 외래키 확정은 4단계에서 수행 |
| REF·AK | 다른 엔티티 참조이면서 단독·복합·조건부 후보키이기도 한 속성 |
| AK(복합) | 둘 이상의 속성이 함께 구성하는 업무상 후보키의 일부 |
| 일반 | 업무 데이터 또는 감사 데이터 |
| 파생 | 저장하지 않고 조회 시 계산하는 값 |
| 필수 | 모든 건에 값이 있어야 함 |
| 선택 | 값이 없어도 됨 |
| 조건부 | 상태나 다른 값에 따라 필수 여부가 달라짐 |

공통 후보 타입은 다음 원칙을 따른다.

- 내부 식별자는 PostgreSQL의 자동 증가 `BIGINT` 후보로 정의한다.
- 업무 날짜는 `DATE`, 시각은 시간대를 포함하는 `TIMESTAMPTZ` 후보로 정의한다.
- 코드와 번호는 정규화한 뒤 빈 문자열을 허용하지 않는다.
- 생성·수정·기록 시각은 일반 사용자가 임의로 바꾸지 못하게 한다.
- 업무값이 실제로 달라지지 않으면 수정 시각과 변경기록을 갱신하지 않는다.
- 감사 스냅샷은 현재 학사정보와 직접 연결하지 않고 당시 식별값과 업무키를 자체 보존한다.

## 4. 엔티티 도출 결과

### 4.1 학사관리 영역(`academic`)

| 엔티티 | 업무상 의미와 발생 단위 | 선정 이유 | 주요 근거 |
|---|---|---|---|
| 학과(Department) | 공식 학과 코드와 학과명을 부여한 교육 조직 하나당 한 건 | 학생과 교수의 현재 소속 기준이 된다. | REQ-DEP-01~04 |
| 학생(Student) | 학번을 부여받은 학생 한 명당 한 건 | 학적·소속을 관리하고 수강과 성적 조회의 주체가 된다. | REQ-STU-01~10 |
| 교수(Professor) | 교번을 부여받은 교수 한 명당 한 건 | 재직·소속을 관리하고 강좌를 담당한다. | REQ-PRO-01~06 |
| 교과목(Subject) | 공식 교과목 코드를 부여한 교육 내용 하나당 한 건 | 여러 학기에 반복 개설되는 교육 내용을 강좌와 분리한다. | REQ-SUB-01~05 |
| 강좌(CourseOffering) | 교과목·연도·학기·분반 조합 하나당 한 건 | 담당 교수, 정원, 개설 상태와 같은 학기별 운영 사실을 가진다. | REQ-CLS-01~10 |
| 수강(Enrollment) | 학생과 강좌의 조합 하나당 최대 한 건 | 학생과 강좌의 다대다 업무를 해소하며 신청·취소·성적 정보를 가진다. | REQ-ENR-01~09, REQ-GRD-01~05 |

학사관리 영역에서는 현재 소속과 상태를 관리한다. 전과, 별도 학적·재직 이력, 강의실, 시간표와 학기 달력은 별도 엔티티로 만들지 않는다. 성적은 수강의 최종 결과로 관리한다.

### 4.2 변경이력·감사 영역(`audit`)

| 엔티티 | 업무상 의미와 발생 단위 | 선정 이유 | 주요 근거 |
|---|---|---|---|
| 업무행위자(AuditActor) | 행위자 코드를 부여한 사람 또는 시스템 하나당 한 건 | 요청자·처리자·승인자·조회자를 공통 기준으로 식별한다. | REQ-ACT-01~04 |
| 행위자역할(AuditActorRole) | 한 행위자에게 부여된 역할과 유효기간 하나당 한 건 | 복수 역할과 처리 당시의 유효 역할을 확인한다. | REQ-ACT-02 |
| 변경요청(ChangeRequest) | 승인 대상 변경 제안 하나당 한 건 | 승인 전 제안값과 사유를 현재 학사정보와 분리해 보존한다. | REQ-APR-01~06 |
| 변경승인(ChangeApproval) | 승인 판단이 이루어진 요청 하나당 최대 한 건 | 승인·반려 판단과 책임자를 불변 기록으로 남긴다. | REQ-APR-03~06 |
| 변경처리(ChangeOperation) | 함께 성공하거나 실패한 실제 업무 처리 한 번당 한 건 | 여러 대상의 변경을 하나의 업무로 묶는다. | REQ-AUD-05~06 |
| 변경기록(ChangeRecord) | 변경된 학사 대상 한 건당 한 건 | 등록·변경·삭제 당시의 전후 내용을 보존한다. | REQ-AUD-01~08 |
| 변경분류(ChangeRecordCategory) | 변경기록에 부여된 감사 분류 하나당 한 건 | 수강 상태·성적 등 복수 분류를 반복 행으로 관리한다. | REQ-AUD-02, REQ-LOG-01~03 |
| 감사조회기록(AuditAccessLog) | 기록 대상 감사 조회 요청 한 번당 한 건 | 누가 어떤 목적으로 감사정보를 조회했는지 남긴다. | REQ-LOG-01~06 |
| 감사보정기록(AuditCorrection) | 감사 원본에 대한 보정 설명 하나당 한 건 | 원본을 수정하지 않고 오류를 설명한다. | REQ-RET-02~03 |
| 보존정책(RetentionPolicy) | 승인된 보존정책 버전 하나당 한 건 | 보존기간과 폐기 기준을 관리한다. | REQ-RET-04~06 |
| 보존보류(RetentionHold) | 특정 범위에 설정된 보류 조치 하나당 한 건 | 분쟁·소송·감사 중인 기록의 폐기를 막는다. | REQ-RET-05 |
| 폐기실행(DisposalExecution) | 승인받아 수행한 폐기 작업 한 번당 한 건 | 실제 폐기 범위와 승인·실행 결과를 증빙한다. | REQ-RET-06 |

### 4.3 엔티티로 채택하지 않은 후보

| 후보 | 판단 이유 |
|---|---|
| 성적 | 수강 한 건에 속하는 현재 최종 결과이며 정정 경위는 공통 변경기록으로 추적한다. |
| 학기 | 학기 달력과 신청 기간이 범위 밖이므로 강좌의 구분값으로 관리한다. |
| 학적·재직·소속 | 학생과 교수의 현재 상태·소속으로 관리하며 별도 업무 이력은 만들지 않는다. |
| 취소 | 수강 상태와 취소 시각으로 표현한다. |
| 개설 상태·수강 상태 | 정해진 소수의 상태값이므로 독립 관리 대상이 아니다. |
| 신입생·재학생·졸업반 | 학년에서 계산하는 표시값이다. |
| 미등록·미정 | 값이 없을 때 조회 화면에서 보여주는 문구다. |
| 스키마 | 업무 영역을 구분하는 공간이며 학사 업무 대상이 아니다. |

정규화·비정규화 종합 검토 결과 총 18개 엔티티를 확정한다. `academic`에는 6개, `audit`에는 12개를 배치한다. 실제 변경 컬럼 목록은 독립 엔티티로 분리하지 않고 `ChangeRecord.changed_columns`에 통제된 배열로 저장한다.

## 5. 학사관리 영역 속성

### 5.1 학과(Department)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `department_id` | 학과 내부 식별자 | PK | 필수 | BIGINT | 시스템 생성, 재사용 금지 |
| `department_code` | 학과 코드 | AK | 필수 | VARCHAR(20) | 영문·숫자·하이픈, 대문자 정규화, 변경 불가 |
| `department_name` | 공식 학과명 | AK | 필수 | VARCHAR(200) | 앞뒤 공백 제거, 영문 대소문자를 무시하여 유일 |
| `created_at` | 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `updated_at` | 수정 시각 | 일반 | 필수 | TIMESTAMPTZ | 실제 변경 때만 갱신 |

### 5.2 학생(Student)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `student_id` | 학생 내부 식별자 | PK | 필수 | BIGINT | 시스템 생성, 재사용 금지 |
| `student_number` | 학번 | AK | 필수 | VARCHAR(20) | 영문·숫자·하이픈, 대문자 정규화, 변경·재사용 금지 |
| `student_name` | 이름 | 일반 | 필수 | VARCHAR(100) | 앞뒤 공백 제거 후 빈 문자열 금지 |
| `email` | 이메일 | AK | 필수 | VARCHAR(254) | 소문자 정규화, 학생 집단 안에서 유일 |
| `grade_year` | 학년 | 일반 | 필수 | SMALLINT | 1~4 |
| `academic_status` | 학적 상태 | 일반 | 필수 | 코드 | `ENROLLED`, `LEAVE`, `GRADUATED`, `EXPELLED` |
| `admission_date` | 입학일 | 일반 | 필수 | DATE | 학생 생성일의 날짜보다 미래일 수 없음 |
| `phone_number` | 전화번호 | 일반 | 선택 | VARCHAR(30) | 중복 허용, `미등록`은 저장하지 않음 |
| `department_id` | 현재 소속 학과 | REF | 필수 | BIGINT | 학과 참조 후보 |
| `created_at` | 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 학생 등록일 판단 기준 |
| `updated_at` | 수정 시각 | 일반 | 필수 | TIMESTAMPTZ | 실제 변경 때만 갱신 |

### 5.3 교수(Professor)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `professor_id` | 교수 내부 식별자 | PK | 필수 | BIGINT | 시스템 생성, 재사용 금지 |
| `employee_number` | 교번 | AK | 필수 | VARCHAR(20) | 영문·숫자·하이픈, 대문자 정규화, 변경·재사용 금지 |
| `professor_name` | 이름 | 일반 | 필수 | VARCHAR(100) | 앞뒤 공백 제거 후 빈 문자열 금지 |
| `email` | 이메일 | AK | 필수 | VARCHAR(254) | 소문자 정규화, 교수 집단 안에서 유일 |
| `employment_status` | 재직 상태 | 일반 | 필수 | 코드 | `ACTIVE`, `RETIRED` |
| `department_id` | 현재 소속 학과 | REF | 필수 | BIGINT | 학과 참조 후보 |
| `created_at` | 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `updated_at` | 수정 시각 | 일반 | 필수 | TIMESTAMPTZ | 실제 변경 때만 갱신 |

### 5.4 교과목(Subject)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `subject_id` | 교과목 내부 식별자 | PK | 필수 | BIGINT | 시스템 생성, 재사용 금지 |
| `subject_code` | 교과목 코드 | AK | 필수 | VARCHAR(20) | 영문·숫자·하이픈, 대문자 정규화, 변경·재사용 금지 |
| `subject_name` | 교과목명 | 일반 | 필수 | VARCHAR(200) | 앞뒤 공백 제거, 중복 허용 |
| `credits` | 학점 | 일반 | 필수 | SMALLINT | 1, 2, 3 중 하나 |
| `created_at` | 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `updated_at` | 수정 시각 | 일반 | 필수 | TIMESTAMPTZ | 실제 변경 때만 갱신 |

### 5.5 강좌(CourseOffering)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `class_id` | 강좌 내부 식별자 | PK | 필수 | BIGINT | 시스템 생성, 재사용 금지 |
| `subject_id` | 대상 교과목 | REF | 필수 | BIGINT | 교과목 참조 후보 |
| `professor_id` | 담당 교수 | REF | 필수 | BIGINT | 교수 참조 후보 |
| `opening_year` | 개설 연도 | 일반 | 필수 | SMALLINT | 2000~2100 |
| `semester` | 학기 | 일반 | 필수 | SMALLINT | 1, 2 중 하나 |
| `section` | 분반 | 일반 | 필수 | VARCHAR(10) | 영문·숫자, 앞뒤 공백 제거 후 대문자 정규화 |
| `capacity` | 수강 정원 | 일반 | 필수 | INTEGER | 1 이상 |
| `opening_status` | 개설 상태 | 일반 | 필수 | 코드 | `RECRUITING`, `CLOSED`, `CANCELLED` |
| `created_at` | 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `updated_at` | 수정 시각 | 일반 | 필수 | TIMESTAMPTZ | 실제 변경 때만 갱신 |

업무 식별자 후보는 `(subject_id, opening_year, semester, section)` 조합이다.

### 5.6 수강(Enrollment)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `enrollment_id` | 수강 내부 식별자 | PK | 필수 | BIGINT | 시스템 생성, 재사용 금지 |
| `student_id` | 학생 | REF | 필수 | BIGINT | 학생 참조 후보 |
| `class_id` | 강좌 | REF | 필수 | BIGINT | 강좌 참조 후보 |
| `enrollment_status` | 신청 상태 | 일반 | 필수 | 코드 | `ENROLLED`, `CANCELLED` |
| `enrolled_at` | 신청 시각 | 일반 | 필수 | TIMESTAMPTZ | 미래 시각 금지 |
| `cancelled_at` | 취소 시각 | 일반 | 조건부 | TIMESTAMPTZ | 취소 상태일 때 필수, 신청 시각 이후 |
| `grade` | 최종 성적 | 일반 | 선택 | VARCHAR(2) | `A+`, `A0`, `B+`, `B0`, `C+`, `C0`, `D+`, `D0`, `F` |
| `grade_updated_at` | 성적 최종 변경 시각 | 일반 | 조건부 | TIMESTAMPTZ | 성적이 있으면 필수 |
| `created_at` | 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `updated_at` | 수정 시각 | 일반 | 필수 | TIMESTAMPTZ | 실제 변경 때만 갱신 |

업무 중복 방지 후보는 `(student_id, class_id)` 조합이다. 취소 원인과 변경 사유는 감사 영역의 변경요청 또는 변경처리에 저장한다.

## 6. 변경이력·감사 영역 속성

### 6.1 업무행위자(AuditActor)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `actor_id` | 행위자 내부 식별자 | PK | 필수 | BIGINT | 시스템 생성, 재사용 금지 |
| `actor_code` | 행위자 코드 | AK | 필수 | VARCHAR(50) | 불변, 빈 문자열 금지 |
| `display_name` | 표시명 | 일반 | 필수 | VARCHAR(100) | 빈 문자열 금지 |
| `actor_kind` | 행위자 종류 | 일반 | 필수 | 코드 | `HUMAN`, `SYSTEM` |
| `is_active` | 활성 여부 | 일반 | 필수 | BOOLEAN | 기본 TRUE, 물리 삭제 대신 비활성화 |
| `student_number_snapshot` | 당시 학번 | 일반 | 선택 | VARCHAR(20) | 학생 행위자인 경우 선택 저장, 학사 FK 없음 |
| `employee_number_snapshot` | 당시 교번 | 일반 | 선택 | VARCHAR(20) | 교수 행위자인 경우 선택 저장, 학사 FK 없음 |
| `created_at` | 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `updated_at` | 수정 시각 | 일반 | 필수 | TIMESTAMPTZ | 표시명·활성 여부 변경 때 갱신 |

### 6.2 행위자역할(AuditActorRole)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `actor_role_id` | 역할 이력 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `actor_id` | 행위자 | REF·AK | 필수 | BIGINT | `role_code`, `valid_from`과 함께 복합 후보키 구성 |
| `role_code` | 역할 | AK(복합) | 필수 | 코드 | `STUDENT`, `PROFESSOR`, `ACADEMIC_STAFF`, `ACADEMIC_MANAGER`, `AUDITOR`, `SYSTEM` |
| `valid_from` | 유효 시작 시각 | AK(복합) | 필수 | TIMESTAMPTZ | 역할 부여 시각 |
| `valid_to` | 유효 종료 시각 | 일반 | 선택 | TIMESTAMPTZ | 값이 있으면 시작 시각보다 늦어야 함 |
| `created_at` | 기록 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |

### 6.3 변경요청(ChangeRequest)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `change_request_id` | 변경요청 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `request_type` | 요청 유형 | 일반 | 필수 | 코드 | 성적 예외 정정, 졸업·제적 진입·해제 등 |
| `requester_actor_id` | 요청자 | REF | 필수 | BIGINT | 업무행위자 참조 후보 |
| `requester_code_snapshot` | 당시 요청자 코드 | 일반 | 필수 | VARCHAR(50) | 요청 생성 시 복사 |
| `requester_name_snapshot` | 당시 요청자 표시명 | 일반 | 필수 | VARCHAR(100) | 요청 생성 시 복사 |
| `target_type` | 대상 유형 | 일반 | 필수 | 코드 | 학사 대상 유형 |
| `target_id_snapshot` | 대상 내부 식별값 | 일반 | 필수 | BIGINT | 현재 학사정보와 직접 연결하지 않음 |
| `business_key_snapshot` | 대상 업무키 | 일반 | 필수 | JSONB | 당시 업무 식별정보 |
| `before_snapshot` | 요청 전 내용 | 일반 | 필수 | JSONB | 요청 생성 당시 전체 업무값 |
| `proposed_after_snapshot` | 제안 후 내용 | 일반 | 필수 | JSONB | 승인 후 적용할 값 |
| `target_version_snapshot` | 대상 버전 기준 | 일반 | 필수 | TIMESTAMPTZ | 오래된 요청 검사에 사용 |
| `reason` | 변경 사유 | 일반 | 필수 | TEXT | 빈 문자열 금지 |
| `request_status` | 요청 상태 | 일반 | 필수 | 코드 | `PENDING`, `REJECTED`, `CANCELLED`, `STALE`, `APPLIED` |
| `cancellation_source` | 수강 취소 원인 | 일반 | 조건부 | 코드 | 해당 요청이 수강 취소일 때 사용 |
| `requested_at` | 요청 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `closed_at` | 종료 시각 | 일반 | 조건부 | TIMESTAMPTZ | 대기 상태에서는 NULL, 종료 상태에서는 필수 |
| `updated_at` | 최종 상태 변경 시각 | 일반 | 필수 | TIMESTAMPTZ | 상태 전이 때만 갱신 |

### 6.4 변경승인(ChangeApproval)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `change_approval_id` | 승인 판단 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `change_request_id` | 변경요청 | REF·AK | 필수 | BIGINT | 단독 후보키, 요청당 최종 판단 최대 1건 |
| `approver_actor_id` | 승인자 | REF | 필수 | BIGINT | 판단 시점에 학사 책임자 역할 필요 |
| `approver_code_snapshot` | 당시 승인자 코드 | 일반 | 필수 | VARCHAR(50) | 판단 시 복사 |
| `approver_name_snapshot` | 당시 승인자 표시명 | 일반 | 필수 | VARCHAR(100) | 판단 시 복사 |
| `decision` | 판단 결과 | 일반 | 필수 | 코드 | `APPROVE`, `REJECT` |
| `decision_reason` | 판단 사유 | 일반 | 조건부 | TEXT | 반려일 때 필수 |
| `decided_at` | 판단 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성, 수정 금지 |
| `recorded_at` | 기록 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 최소 5년 보존 기준 |

### 6.5 변경처리(ChangeOperation)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `change_operation_id` | 변경처리 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `change_request_id` | 적용 근거 요청 | REF·AK | 선택 | BIGINT | 승인 요청에서 적용된 처리일 때 사용, NULL이 아닌 값은 유일 |
| `requester_actor_id` | 업무 요청자 | REF | 선택 | BIGINT | 실제 처리자와 요청자가 다른 경우 |
| `initiator_actor_id` | 최초 처리 시작자 | REF | 필수 | BIGINT | 업무를 시작한 행위자 |
| `executor_actor_id` | 실제 실행 행위자 | REF | 필수 | BIGINT | 시스템 후속 처리라면 시스템 행위자 |
| `requester_code_snapshot` | 당시 요청자 코드 | 일반 | 선택 | VARCHAR(50) | 요청자가 있을 때 행위자에서 복사 |
| `requester_name_snapshot` | 당시 요청자 표시명 | 일반 | 선택 | VARCHAR(100) | 요청자가 있을 때 행위자에서 복사 |
| `initiator_code_snapshot` | 당시 시작자 코드 | 일반 | 필수 | VARCHAR(50) | 처리 시작 시 행위자에서 복사 |
| `initiator_name_snapshot` | 당시 시작자 표시명 | 일반 | 필수 | VARCHAR(100) | 처리 시작 시 행위자에서 복사 |
| `executor_code_snapshot` | 당시 실행자 코드 | 일반 | 필수 | VARCHAR(50) | 처리 실행 시 행위자에서 복사 |
| `executor_name_snapshot` | 당시 실행자 표시명 | 일반 | 필수 | VARCHAR(100) | 처리 실행 시 행위자에서 복사 |
| `execution_source` | 실행 출처 | 일반 | 필수 | 코드 | `USER`, `SYSTEM`, `IMPORT` |
| `reason` | 변경 사유 | 일반 | 조건부 | TEXT | 변경·삭제 및 중요 변경은 필수 |
| `is_important` | 중요 변경 포함 여부 | 일반 | 필수 | BOOLEAN | 조회용 요약값, 변경분류·전후값과 같은 트랜잭션에서 검증 |
| `cancellation_source` | 수강 취소 원인 | 일반 | 조건부 | 코드 | `STUDENT_REQUEST`, `ADMIN_OVERRIDE`, `COURSE_CANCELLED` |
| `correlation_id` | 외부 요청 연계값 | 일반 | 선택 | UUID | 여러 처리의 업무상 연관 표시 |
| `occurred_at` | 업무 발생 시각 | 일반 | 필수 | TIMESTAMPTZ | 실제 변경 발생 시각 |
| `recorded_at` | 감사 적재 시각 | 일반 | 필수 | TIMESTAMPTZ | 최소 5년 보존 기준 |

### 6.6 변경기록(ChangeRecord)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `change_record_id` | 변경기록 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `change_operation_id` | 변경처리 | REF·AK | 필수 | BIGINT | `record_sequence`와 함께 복합 후보키 구성 |
| `record_sequence` | 처리 내 순번 | AK(복합) | 필수 | INTEGER | `change_operation_id` 안에서 유일 |
| `operation_type` | 처리 종류 | 일반 | 필수 | 코드 | `CREATE`, `UPDATE`, `DELETE` |
| `target_type` | 대상 유형 | 일반 | 필수 | 코드 | 학사 대상 유형 |
| `target_id_snapshot` | 당시 내부 식별값 | 일반 | 필수 | BIGINT | 현재 학사정보와 직접 연결하지 않음 |
| `business_key_snapshot` | 당시 업무키 | 일반 | 필수 | JSONB | 삭제 후에도 유지 |
| `before_snapshot` | 변경 전 내용 | 일반 | 조건부 | JSONB | 등록에서는 NULL |
| `after_snapshot` | 변경 후 내용 | 일반 | 조건부 | JSONB | 삭제에서는 NULL |
| `changed_columns` | 실제 변경 컬럼 목록 | 일반·의도적 비정규화 | 필수 | TEXT[] | 시스템 생성, 중복·빈 문자열 금지, 사용자 직접 입력·수정 금지 |
| `student_number_tag` | 학생 검색 태그 | 일반 | 선택 | VARCHAR(20) | 학생·수강·성적 흐름 검색용 |
| `subject_code_tag` | 강좌 교과목 코드 태그 | 일반 | 선택 | VARCHAR(20) | 강좌·수강·성적 흐름 검색용 |
| `opening_year_tag` | 강좌 개설 연도 태그 | 일반 | 선택 | SMALLINT | 강좌키가 있는 기록에서 사용 |
| `semester_tag` | 강좌 학기 태그 | 일반 | 선택 | SMALLINT | 1 또는 2 |
| `section_tag` | 강좌 분반 태그 | 일반 | 선택 | VARCHAR(10) | 정규화된 분반 |
| `snapshot_schema_version` | 스냅샷 구조 버전 | 일반 | 필수 | INTEGER | 1 이상 |
| `recorded_at` | 기록 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성, 수정 금지 |

`changed_columns`는 감사 생성 함수가 정규화된 전후 스냅샷을 비교해 같은 트랜잭션에서 만든다. UPDATE에서는 원소가 최소 1개여야 하며 CREATE·DELETE에서는 빈 배열을 허용한다. 전후 스냅샷이 변경 사실의 원본이고 배열은 조회·표시용 보조값이다.

### 6.7 변경분류(ChangeRecordCategory)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `change_record_category_id` | 변경분류 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `change_record_id` | 변경기록 | REF·AK | 필수 | BIGINT | `category_code`와 함께 복합 후보키 구성 |
| `category_code` | 감사 분류 코드 | AK(복합) | 필수 | VARCHAR(50) | 같은 변경기록 안에서 유일 |

모든 변경기록은 변경분류를 최소 한 건 가져야 한다. 수강 상태와 성적이 함께 달라지면 서로 다른 분류 행을 함께 저장한다.

### 6.8 감사조회기록(AuditAccessLog)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `access_log_id` | 조회기록 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `viewer_actor_id` | 조회자 | REF | 필수 | BIGINT | 업무행위자 참조 후보 |
| `viewer_code_snapshot` | 당시 조회자 코드 | 일반 | 필수 | VARCHAR(50) | 조회 시 복사 |
| `viewer_name_snapshot` | 당시 조회자 표시명 | 일반 | 필수 | VARCHAR(100) | 조회 시 복사 |
| `access_type` | 조회 유형 | 일반 | 필수 | 코드 | `SEARCH`, `DETAIL`, `EXPORT` |
| `target_audit_type` | 조회 대상 감사정보 | 일반 | 필수 | 코드 | 요청, 승인, 처리, 변경기록 등 |
| `access_purpose` | 조회 목적 | 일반 | 필수 | TEXT | 빈 문자열 금지 |
| `filter_snapshot` | 조회 조건 | 일반 | 필수 | JSONB | 실행 당시 조건 |
| `result_count` | 결과 건수 | 일반 | 조건부 | INTEGER | 성공 시 0 이상 |
| `is_success` | 성공 여부 | 일반 | 필수 | BOOLEAN | 실패 조회도 기록 |
| `failure_detail` | 실패 내용 | 일반 | 조건부 | TEXT | 실패 시 필수 |
| `accessed_at` | 조회 시각 | 일반 | 필수 | TIMESTAMPTZ | 최소 5년 보존 기준 |

### 6.9 감사보정기록(AuditCorrection)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `audit_correction_id` | 보정기록 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `original_record_type` | 원본 감사기록 유형 | 일반 | 필수 | 코드 | 보정 대상 유형 |
| `original_record_id` | 원본 감사기록 식별값 | 일반 | 필수 | BIGINT | 감사 원본을 논리 참조 |
| `correction_reason` | 보정 사유 | 일반 | 필수 | TEXT | 빈 문자열 금지 |
| `correct_explanation` | 올바른 설명 | 일반 | 필수 | TEXT | 원본을 대체하지 않는 설명 |
| `corrector_actor_id` | 보정 처리자 | REF | 필수 | BIGINT | 업무행위자 참조 후보 |
| `corrector_code_snapshot` | 당시 처리자 코드 | 일반 | 필수 | VARCHAR(50) | 보정 시 복사 |
| `corrector_name_snapshot` | 당시 처리자 표시명 | 일반 | 필수 | VARCHAR(100) | 보정 시 복사 |
| `recorded_at` | 보정 기록 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성, 수정 금지 |

### 6.10 보존정책(RetentionPolicy)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `retention_policy_id` | 정책 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `policy_code` | 정책 코드 | AK(복합) | 필수 | VARCHAR(50) | `version_number`와 함께 후보키 구성 |
| `version_number` | 정책 버전 | AK(복합) | 필수 | INTEGER | 정책 코드 안에서 유일 |
| `policy_name` | 정책명 | 일반 | 필수 | VARCHAR(200) | 빈 문자열 금지 |
| `policy_scope` | 적용 범위 | 일반 | 필수 | JSONB | 대상 감사정보와 조건 |
| `minimum_retention_years` | 최소 보존 연수 | 일반 | 필수 | SMALLINT | 5 이상 |
| `effective_from` | 적용 시작 시각 | 일반 | 필수 | TIMESTAMPTZ | 승인 이후 |
| `effective_to` | 적용 종료 시각 | 일반 | 선택 | TIMESTAMPTZ | 시작 시각보다 늦어야 함 |
| `policy_status` | 정책 상태 | 일반 | 필수 | 코드 | `ACTIVE`, `RETIRED` |
| `approved_by_actor_id` | 정책 승인자 | REF | 필수 | BIGINT | 학사 책임자 역할 |
| `approver_code_snapshot` | 당시 승인자 코드 | 일반 | 필수 | VARCHAR(50) | 승인 시 행위자에서 복사 |
| `approver_name_snapshot` | 당시 승인자 표시명 | 일반 | 필수 | VARCHAR(100) | 승인 시 행위자에서 복사 |
| `approved_at` | 정책 승인 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `recorded_at` | 기록 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 최소 5년 보존 기준 |

### 6.11 보존보류(RetentionHold)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `retention_hold_id` | 보존보류 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `target_scope_type` | 보류 대상 유형 | 일반 | 필수 | 코드 | 학생, 강좌, 변경처리, 기간 등 |
| `target_scope_snapshot` | 보류 대상 범위 | 일반 | 필수 | JSONB | 현재 학사정보와 직접 연결하지 않음 |
| `hold_reason` | 보류 사유 | 일반 | 필수 | TEXT | 빈 문자열 금지 |
| `placed_by_actor_id` | 보류 설정자 | REF | 필수 | BIGINT | 업무행위자 참조 후보 |
| `placer_code_snapshot` | 당시 설정자 코드 | 일반 | 필수 | VARCHAR(50) | 설정 시 행위자에서 복사 |
| `placer_name_snapshot` | 당시 설정자 표시명 | 일반 | 필수 | VARCHAR(100) | 설정 시 행위자에서 복사 |
| `placed_at` | 보류 설정 시각 | 일반 | 필수 | TIMESTAMPTZ | 시스템 생성 |
| `released_by_actor_id` | 보류 해제자 | REF | 조건부 | BIGINT | 해제됐을 때 필수 |
| `releaser_code_snapshot` | 당시 해제자 코드 | 일반 | 조건부 | VARCHAR(50) | 해제됐을 때 필수 |
| `releaser_name_snapshot` | 당시 해제자 표시명 | 일반 | 조건부 | VARCHAR(100) | 해제됐을 때 필수 |
| `release_reason` | 해제 사유 | 일반 | 조건부 | TEXT | 해제됐을 때 필수 |
| `released_at` | 보류 해제 시각 | 일반 | 선택 | TIMESTAMPTZ | 설정 시각보다 늦어야 함 |
| `recorded_at` | 기록 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 최소 5년 보존 기준 |

### 6.12 폐기실행(DisposalExecution)

| 속성 후보 | 업무명 | 구분 | 필수성 | 타입·도메인 후보 | 규칙 |
|---|---|---|---|---|---|
| `disposal_execution_id` | 폐기실행 식별자 | PK | 필수 | BIGINT | 시스템 생성 |
| `retention_policy_id` | 적용 보존정책 | REF | 필수 | BIGINT | 보존정책 참조 후보 |
| `target_period_from` | 폐기 대상 시작 시각 | 일반 | 필수 | TIMESTAMPTZ | 대상 기간 하한 |
| `target_period_to` | 폐기 대상 종료 시각 | 일반 | 필수 | TIMESTAMPTZ | 시작 시각 이후 |
| `target_scope_snapshot` | 폐기 대상 범위 | 일반 | 필수 | JSONB | 실행 당시 범위 |
| `approved_by_actor_id` | 실행 승인자 | REF | 필수 | BIGINT | 학사 책임자, 실행자와 구분 |
| `approver_code_snapshot` | 당시 승인자 코드 | 일반 | 필수 | VARCHAR(50) | 승인 시 행위자에서 복사 |
| `approver_name_snapshot` | 당시 승인자 표시명 | 일반 | 필수 | VARCHAR(100) | 승인 시 행위자에서 복사 |
| `approved_at` | 실행 승인 시각 | 일반 | 필수 | TIMESTAMPTZ | 실행 이전 |
| `executed_by_actor_id` | 실행자 | REF | 조건부 | BIGINT | 실행 시작 후 필수 |
| `executor_code_snapshot` | 당시 실행자 코드 | 일반 | 조건부 | VARCHAR(50) | 실행 시작 후 필수 |
| `executor_name_snapshot` | 당시 실행자 표시명 | 일반 | 조건부 | VARCHAR(100) | 실행 시작 후 필수 |
| `execution_status` | 실행 상태 | 일반 | 필수 | 코드 | `APPROVED`, `RUNNING`, `COMPLETED`, `PARTIAL`, `FAILED` |
| `executed_at` | 실행 완료 시각 | 일반 | 조건부 | TIMESTAMPTZ | 종료 상태에서 필수 |
| `deleted_record_count` | 폐기 건수 | 일반 | 조건부 | BIGINT | 종료 상태에서 0 이상 |
| `result_snapshot` | 처리 결과 | 일반 | 조건부 | JSONB | 완료·부분·실패 결과와 오류 요약 |
| `recorded_at` | 증적 생성 시각 | 일반 | 필수 | TIMESTAMPTZ | 삭제 대상과 분리하여 최소 5년 보존 |

## 7. 저장하지 않는 파생·표시 속성

| 파생값 | 계산 근거 | 표현 방식 |
|---|---|---|
| 전화번호 표시 | 학생 전화번호 | 값이 없으면 `미등록` |
| 학년 안내 | 학생 학년 | 1학년 `신입생`, 2~3학년 `재학생`, 4학년 `졸업반` |
| 입학 연도 | 학생 입학일 | 입학일에서 연도 추출 |
| 강좌 수강 인원 | 수강 상태 | 해당 강좌의 신청 완료 건수 |
| 성적 표시 | 수강 성적 | 값이 없으면 `미정` |
| 잔여석 | 정원과 수강 인원 | 정원 - 현재 신청 완료 인원 |
| 감사기록 보존 만료 시각 | 기록 생성 시각 | 기록 생성 시각 + 5년 |
| 보존보류 활성 여부 | 보류 해제 시각 | 해제 시각이 없으면 활성 |

과거 재구성에 필요한 업무키와 행위자 표시명 스냅샷은 파생값이 아니라 저장 속성이다.

## 8. 복수 속성 무결성 규칙

### 8.1 학사관리 영역

- 학생 입학일은 학생 생성일보다 미래일 수 없다.
- 강좌의 교과목·연도·학기·분반 조합은 중복될 수 없다.
- 수강의 학생·강좌 조합은 중복될 수 없다.
- 신청 완료 상태이면 취소 시각이 없어야 한다.
- 수강 취소 상태이면 취소 시각이 필요하고 신청 시각보다 빠를 수 없다.
- 성적과 성적 최종 변경 시각은 함께 존재하거나 함께 없어야 한다.
- 취소된 수강 건에는 성적을 저장할 수 없다.

### 8.2 변경요청과 승인

- 변경요청의 요청자와 승인자는 같을 수 없다.
- 대기 상태인 요청에는 종료 시각이 없고 종료 상태에는 종료 시각이 있어야 한다.
- 승인 판단과 요청 적용, 실제 변경처리는 같은 업무 안에서 이루어져야 한다.
- 적용 직전 현재값이 요청 당시 값과 다르면 요청을 오래된 상태로 종료한다.
- 한 변경요청에는 최종 승인 또는 반려 판단이 최대 한 건만 존재한다.

### 8.3 변경처리와 변경기록

- 하나의 변경처리는 하나의 원자적인 데이터베이스 처리와 일치한다.
- 등록 기록은 변경 전 내용이 없고 변경 후 내용이 있어야 한다.
- UPDATE 기록은 전후 내용과 비어 있지 않은 `changed_columns`를 가져야 한다.
- 삭제 기록은 변경 전 내용이 있고 변경 후 내용이 없어야 한다.
- CREATE·DELETE 기록은 빈 `changed_columns` 배열을 허용한다.
- `changed_columns`에는 중복·빈 문자열·허용되지 않은 컬럼명이나 실제로 바뀌지 않은 컬럼명을 저장할 수 없다.
- 정규화한 업무값이 같으면 변경기록과 수정 시각을 만들지 않는다.
- 학사 변경과 감사기록은 함께 성공하거나 함께 취소되어야 한다.

### 8.4 조회·보존·폐기

- 감사 조회 목적은 필수이며 성공·실패 조회를 모두 기록한다.
- 실패 조회에는 실패 내용이, 성공 조회에는 결과 건수가 필요하다.
- 보존보류의 해제자·해제사유·해제시각은 모두 함께 존재하거나 모두 없어야 한다.
- 폐기 실행은 승인 시각 이후에만 시작할 수 있다.
- 5년이 지나지 않았거나 활성 보존보류가 있는 기록은 폐기할 수 없다.
- 감사 원본은 수정하지 않으며 오류는 감사보정기록으로만 설명한다.

## 9. 단계 검증 결과

| 검증 항목 | 결과 | 확인 내용 |
|---|---|---|
| 엔티티 누락 여부 | 통과 | `academic` 6개와 `audit` 12개를 포함했다. |
| 모델 정제 원칙 충족 여부 | 통과 | 독립 업무 사실은 분리하고 변경 컬럼 목록만 통제된 `TEXT[]`로 구성했다. |
| 범위 밖 엔티티 유입 여부 | 통과 | 로그인, 학기 달력, 강의실, 시간표와 업무별 상태 이력을 제외했다. |
| 교과목과 강좌 구분 | 통과 | 교육 내용과 학기별 실제 운영 단위를 구분했다. |
| 학생·강좌 관계 해소 | 통과 | 수강을 연결 엔티티로 채택했다. |
| 내부·업무 식별자 구분 | 통과 | 내부 PK와 코드·번호·복합 업무키를 구분했다. |
| 필수·선택 구분 | 통과 | 상태별 조건부 필수값을 표시했다. |
| 성적 모델 일치 | 통과 | 성적을 수강 속성으로 유지했다. |
| 학사·감사 영역 분리 | 통과 | 감사 대상 식별값은 스냅샷이며 학사 REF로 표시하지 않았다. |
| 삭제 후 재구성 | 통과 | 업무키, 전후 내용과 행위자 정보를 스냅샷으로 보존한다. |
| 파생값 중복 방지 | 통과 | 미등록·학년 안내·미정·수강 인원·잔여석을 파생값으로 분리했다. |

## 10. 다음 단계 입력

이 문서의 REF 또는 REF·AK 속성을 기준으로 4·5단계 관계와 카디널리티를 정의한다. 변경분류 관계와 `changed_columns` 배열 검증 규칙을 `erd-04-to-05-relationships-cardinality.md`에 반영한다.
