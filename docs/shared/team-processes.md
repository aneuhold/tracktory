# Team Processes

_Essential collaboration patterns between chat modes_

## Role Responsibilities

### Product Strategist (`docs/strategy/`)

- High-level product vision and market strategy
- Competitive analysis and strategic roadmaps
- Business objectives and success metrics

### Product Manager (`docs/product/`)

- User stories and feature requirements
- Product backlog and release planning
- User research and validation

### Architect (`docs/architecture/`)

- System design and technical architecture
- Technology decisions and technical roadmaps
- API specifications and integration patterns

### UX Designer (`docs/design/`)

- User research and experience design
- Wireframes, prototypes, and design systems
- User journey mapping and usability testing

### QA Engineer (`docs/quality/`)

- Test strategy and quality standards
- Test plans and execution
- Quality metrics and reporting

### DevOps Engineer (`docs/infrastructure/`)

- Deployment and infrastructure management
- Monitoring and observability
- CI/CD pipelines and automation

## Communication

Use the inbox system for cross-role tasks and requests. Each role checks their `inbox.md` file and maintains their own working documents in their domain folder.

## Documentation Standards

All roles follow shared documentation standards for consistency and maintainability. Focus on actionable, current information that supports development work.

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
