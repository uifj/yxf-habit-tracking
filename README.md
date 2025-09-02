# yxf-habit-tracking
This is a cross-platform application that grows driven by goals!

太棒了！为一个新的Flutter项目搭建企业级Git协作流程是项目成功的关键一步。这不仅能确保代码质量，还能极大地提高团队协作效率。

作为一名资深专家，我将为你提供一套完整、可立即落地的方案。这套方案结合了Git分支策略、自动化工具链和项目管理实践，是现代敏捷团队的标准配置。

企业级Git协作完整配置指南

以下是为你的3人Flutter团队设计的完整步骤：

第一阶段：仓库初始化与基础配置

1. 设置分支保护规则

这是最重要的一步，可以防止主分支被意外破坏。

•   路径: 仓库首页 -> Settings -> Branches -> Add branch protection rule

•   分支模式: main (或 master, develop - 取决于你的基准分支)

•   必须勾选的规则:

    ◦   Require a pull request before merging: 强制所有代码必须通过PR合并

        ▪   勾选 Require approvals 并设置为 至少1人 (3人团队1人审批即可)

        ▪   勾选 Require review from Code Owners

    ◦   Require status checks to pass before merging: 强制CI/CD流程通过后才能合并

        ▪   在下面选择你的CI检查项（如ci/circleci: build或lint）

    ◦   Include administrators: 确保规则对所有人生效

    ◦   Restrict who can push to matching branches: 设置为无人可直接推送，必须通过PR。

2. 设置CODEOWNERS文件

定义代码库不同部分的负责人，他们的评审对相应区域的代码变更必须通过。

•   路径: 在仓库根目录或 .github/ 目录下创建名为 CODEOWNERS 的文件

•   内容示例:
    # 全局默认所有者（对任何文件都生效）
    *       @your-github-username @teammate1 @teammate2

    # 指定目录/文件的所有者，常用于核心模块
    /lib/src/core/    @your-github-username
    /ios/             @teammate1
    /android/         @teammate2
    /pubspec.yaml     @your-github-username @teammate1 # 关键文件需多人审批
    
•   作用: 当PR修改了/ios/目录下的文件时，@teammate1会自动被请求评审。

3. 配置Issue和PR模板

标准化沟通，确保提交的信息完整、一致。

•   路径: 在 .github/ 目录下创建 ISSUE_TEMPLATE/ 和 PULL_REQUEST_TEMPLATE.md

•   Issue模板示例 (.github/ISSUE_TEMPLATE/bug_report.md):
    name: 🐛 Bug Report
    description: 报告一个可复现的Bug
    title: "[Bug]: "
    labels: ["bug"]
    body:
      - type: textarea
        attributes:
          label: 当前行为
          description: 描述实际发生了什么。
        validations:
          required: true
      - type: textarea
        attributes:
          label: 预期行为
          description: 描述你期望发生什么。
        validations:
          required: true
      - type: textarea
        attributes:
          label: 复现步骤
          description: 清晰描述如何复现这个Bug。
          placeholder: |
            1. 进入 '...'
            2. 点击 '....'
            3. 看到错误
        validations:
          required: true
      - type: dropdown
        attributes:
          label: 影响平台
          description: 选择受影响的平台。
          multiple: true
          options:
            - Android
            - iOS
            - Web
        validations:
          required: true
    
•   PR模板示例 (.github/PULL_REQUEST_TEMPLATE.md):
    ## 描述
    <!-- 请简要描述这个PR做了什么 -->

    ## 相关Issue
    <!-- 通过关键字关闭相关Issue，例如：Closes #123, Fixes #456 -->
    - Closes #

    ## 类型变更
    <!-- 删除不相关的选项 -->
    - [ ] Bug修复
    - [ ] 新功能
    - [ ] 破坏性变更（修复或功能导致现有API不兼容）
    - [ ] 文档更新

    ## 检查清单
    <!-- 在提交PR前，请确保你完成了以下步骤 -->
    - [ ] 我的代码遵循了项目的代码风格
    - [ ] 我自测了所有受影响的功能
    - [ ] 我添加或更新了必要的测试
    - [ ] 我添加或更新了必要的文档

    ## 附注
    <!-- 屏幕截图、屏幕录制或其他对评审者有帮助的信息 -->
    

第二阶段：Git分支策略（推荐 Git Flow 简化版）

对于移动应用团队，一套清晰的分支策略至关重要，因为它涉及版本发布和热修复。

•   main 分支: 对应生产环境代码。永远稳定，每次提交都对应一个发布版本（打Tag）。

•   develop 分支: 集成最新开发成果的分支。功能分支基于此分支创建，并合并回此分支。相对稳定。

•   feature/* 分支: 从 develop 拉取，用于开发新功能。命名如 feature/user-auth, feature/payment。

    ◦   创建: git checkout -b feature/awesome-feature develop

    ◦   合并: 通过PR合并回 develop

•   release/* 分支: 从 develop 拉取，用于准备发布新版本（版本号、最终测试）。命名如 release/1.2.0。

    ◦   测试通过后，合并到 main 和 develop。

•   hotfix/* 分支: 从 main 拉取，用于紧急修复生产环境的Bug。命名如 hotfix/critical-crash。

    ◦   修复后，合并回 main (打新Tag) 和 develop。

工作流图示:
graph LR
    A[feature/*] --PR--> B[develop]
    B --PR--> C[release/*]
    C --PR--> D[main]
    E[hotfix/*] --PR--> D
    E --PR--> B
    D --Tag vX.Y.Z--> F[Production]


第三阶段：自动化工具链（CI/CD）

这是企业级流程的“肌肉”，自动完成代码检查、测试和构建。

1. 基础质量门禁（GitHub Actions）

在 .github/workflows/ 下创建YAML文件，例如 ci.yml:
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable' # 或你指定的版本
      - run: flutter pub get
      - run: flutter test # 运行单元测试
      - run: flutter analyze --fatal-infos --fatal-warnings # 静态分析，必须无错误和无警告
      - run: flutter build apk --debug --no-tree-shake-icons # 或尝试构建iOS包，确保无编译错误

  format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter format --set-exit-if-changed . # 检查代码格式，如果格式不正确则失败


2. 代码规范与提交信息规范

•   代码格式化: 统一使用 flutter format . 格式化代码。可以在预提交钩子中自动完成。

•   提交信息规范: 推荐使用 Conventional Commits，便于生成变更日志。
    feat: 添加用户登录功能
    fix: 修复首页列表滚动卡顿问题
    docs: 更新README安装说明
    chore: 更新CI脚本
    
•   工具推荐: 使用 commitlint 和 husky 在本地强制规范提交信息（需配置Node.js环境）。

第四阶段：项目管理实践

1. 项目看板

使用GitHub Projects或Linear、Jira等工具创建看板，管理任务状态（待办、进行中、已完成）。

2. 定期Code Review

•   PR描述清晰，说明做了什么和为什么这么做。

•   评审者关注代码逻辑、架构、性能、测试覆盖率和命名等。

•   使用“点赞”和“评论”分开的原则。小问题直接评论，需要修改的请求使用“请求更改”。

3. 团队沟通约定

•   每日站会: 同步进度、阻塞问题。

•   定义“完成”标准: 例如，一个任务必须包括：代码实现、通过评审、测试通过、文档更新。

总结与建议

对于你的3人Flutter团队，我建议的最小可行配置是：

1.  立即执行: 分支保护规则 + PR模板。这是性价比最高、最能立即避免灾难的配置。
2.  第一周内添加: CI流水线（执行测试和静态分析），确保合并的代码基本健康。
3.  逐步推行: 在团队内讨论并确定分支策略（Git Flow），然后推行CODEOWNERS和提交信息规范。

这套流程看似复杂，但一旦搭建完成，它将成为团队的“自动驾驶系统”，让你们能更专注于创造业务价值，而不是解决协作冲突和代码质量问题。

祝项目顺利！如果有任何具体问题，随时可以再问。