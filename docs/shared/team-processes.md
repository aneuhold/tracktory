# Team Processes & Collaboration

_Cross-functional process documentation for effective collaboration between chat modes and development workflows_

## Chat Mode Collaboration Workflows

### Strategic Planning Flow

```
Product Strategist → Product Manager → UX Designer
        ↓                ↓              ↓
    Vision & Goals → Requirements → User Experience
        ↓                ↓              ↓
    Documents:       Documents:     Documents:
    - product-vision.md  - user-stories.md  - user-journeys.md
    - strategic-roadmap.md - requirements.md - wireframes/
    - market-analysis.md   - backlog.md      - user-research.md
```

### Technical Implementation Flow

```
Architect → You (Developer) → QA Engineer → DevOps Engineer
    ↓            ↓               ↓             ↓
Technical    Implementation   Quality      Deployment
Design       & Code          Assurance    & Operations
    ↓            ↓               ↓             ↓
Documents:   Code & Tests    Documents:   Documents:
- system-design.md           - test-strategy.md  - deployment-guide.md
- technical-decisions.md     - test-plans.md     - monitoring.md
- api-specifications.md      - quality-metrics.md - infrastructure-as-code.md
```

## Document Handoff Patterns

### 1. Vision to Requirements (Product Strategist → Product Manager)

**Trigger**: New strategic initiative or market opportunity
**Input Documents**:

- `strategy/product-vision.md`
- `strategy/market-analysis.md`
- `strategy/strategic-roadmap.md`

**Output Documents**:

- `product/requirements.md`
- `product/user-stories.md`
- `product/backlog.md`

**Process**:

1. Product Strategist defines vision and strategic goals
2. Product Manager translates strategy into detailed requirements
3. Both review and align on priorities and scope
4. Product Manager updates user stories and backlog

### 2. Requirements to Design (Product Manager → UX Designer)

**Trigger**: New feature requirements or user story creation
**Input Documents**:

- `product/user-stories.md`
- `product/requirements.md`
- `product/user-personas.md`

**Output Documents**:

- `design/user-journeys.md`
- `design/wireframes/`
- `design/user-research.md`

**Process**:

1. UX Designer reviews requirements and user stories
2. Conducts user research if needed
3. Creates user journeys and wireframes
4. Product Manager validates against requirements

### 3. Design to Architecture (UX Designer + Product Manager → Architect)

**Trigger**: Design completion or technical planning phase
**Input Documents**:

- `design/user-journeys.md`
- `design/wireframes/`
- `product/user-stories.md`

**Output Documents**:

- `architecture/system-design.md`
- `architecture/technical-decisions.md`
- `architecture/api-specifications.md`

**Process**:

1. Architect reviews design and requirements
2. Creates technical design and specifications
3. UX Designer and Product Manager review for feasibility
4. All parties align on technical approach

### 4. Architecture to Implementation (Architect → Developer → QA)

**Trigger**: Technical design completion
**Input Documents**:

- `architecture/system-design.md`
- `architecture/api-specifications.md`
- `product/user-stories.md`

**Output Documents**:

- Code implementation
- `quality/test-plans.md`
- `quality/test-cases.md`

**Process**:

1. Developer implements based on architecture and stories
2. QA Engineer creates test plans from requirements and design
3. All parties coordinate on acceptance criteria validation
4. QA Engineer validates implementation against requirements

### 5. Implementation to Deployment (Developer + QA → DevOps)

**Trigger**: Feature completion and quality validation
**Input Documents**:

- Completed code and tests
- `quality/test-strategy.md`
- `architecture/system-design.md`

**Output Documents**:

- `infrastructure/deployment-guide.md`
- `infrastructure/monitoring.md`
- `product/release-notes.md`

**Process**:

1. DevOps Engineer prepares deployment and infrastructure
2. QA Engineer validates in staging environment
3. All parties coordinate on release timeline
4. Product Manager updates release notes

## Meeting Cadences & Touchpoints

### Weekly Cross-Functional Sync

**Participants**: All chat modes + Developer
**Duration**: 30 minutes
**Agenda**:

- Progress updates from each domain
- Document review and alignment
- Blockers and dependencies
- Upcoming priorities

**Documents Updated**:

- `shared/meeting-notes.md`
- Status updates in respective domain docs

### Sprint Planning (Bi-weekly)

**Participants**: Product Manager, UX Designer, Developer, QA Engineer
**Duration**: 2 hours
**Agenda**:

- Review and refine user stories
- Estimate effort and complexity
- Plan sprint deliverables
- Identify dependencies and risks

**Documents Updated**:

- `product/user-stories.md` (status updates)
- `product/backlog.md` (sprint planning)

### Architecture Review (Monthly)

**Participants**: Architect, Product Strategist, DevOps Engineer, Developer
**Duration**: 1 hour
**Agenda**:

- Review architectural decisions
- Plan technical improvements
- Assess technical debt
- Align on technology strategy

**Documents Updated**:

- `architecture/technical-decisions.md`
- `strategy/strategic-roadmap.md` (technical considerations)

## Document Review Cycles

### Daily Updates

- **Owner**: Updates their primary documents with progress
- **Time**: End of day
- **Scope**: Status, blockers, decisions made

### Weekly Reviews

- **Cross-functional**: Review shared documents for alignment
- **Time**: Start of week
- **Scope**: Major changes, new requirements, strategy shifts

### Sprint Reviews

- **Complete review**: All active documents validated
- **Time**: End of sprint
- **Scope**: Deliverables, lessons learned, process improvements

## Communication Standards

### Document Updates

- **Commit Message Format**: `docs(domain): brief description`
  - Examples: `docs(product): add authentication user stories`
  - Examples: `docs(architecture): update API specifications for auth`

### Cross-References

- **Always link** related documents using relative paths
- **Update references** when documents change
- **Include context** when referencing other domains

### Change Notifications

- **Major Changes**: Notify affected team members
- **Breaking Changes**: Require cross-functional review
- **New Documents**: Announce in team sync

## Conflict Resolution

### Document Conflicts

1. **Identify**: Who are the stakeholders affected?
2. **Discuss**: Schedule focused discussion with relevant parties
3. **Decide**: Product Strategist makes final call on priority conflicts
4. **Document**: Update `shared/decisions-log.md` with rationale

### Process Improvements

1. **Identify**: Process inefficiency or collaboration gap
2. **Propose**: Suggest improvement in team sync
3. **Trial**: Test new approach for one sprint
4. **Adopt/Reject**: Decide based on results and update this document

## Success Metrics

### Documentation Health

- **Freshness**: Documents updated within last week
- **Completeness**: All major features have documentation
- **Cross-References**: Links are valid and helpful

### Collaboration Effectiveness

- **Handoff Speed**: Time from document completion to next phase start
- **Alignment**: Reduced rework due to miscommunication
- **Visibility**: Team members can find information quickly

### Process Efficiency

- **Meeting Effectiveness**: Decisions made and documented
- **Document Utility**: Documents referenced and useful
- **Change Management**: Smooth process when requirements change
