#
# Манифест модуля для модуля "powershell-for-gitlab".
#
# Создано: Volobuev
#
# Дата создания: 04.05.2021
#

@{

  # Файл модуля сценария или двоичного модуля, связанный с этим манифестом.
  # RootModule = ''

  # Номер версии данного модуля.
  ModuleVersion     = '0.2.0'

  # Поддерживаемые выпуски PSEditions
  # CompatiblePSEditions = @()

  # Уникальный идентификатор данного модуля
  GUID              = '48d407a6-686a-4611-aba0-3e69fe5830d9'

  # Автор данного модуля
  Author            = 'Musisimaru'

  # Компания, создавшая данный модуль, или его поставщик
  CompanyName       = ''

  # Заявление об авторских правах на модуль
  Copyright         = '(c) 2021 Musisimaru. Все права защищены.'

  # Описание функций данного модуля
  # Description = ''

  # Минимальный номер версии обработчика Windows PowerShell, необходимой для работы данного модуля
  # PowerShellVersion = ''

  # Имя узла Windows PowerShell, необходимого для работы данного модуля
  # PowerShellHostName = ''

  # Минимальный номер версии узла Windows PowerShell, необходимой для работы данного модуля
  # PowerShellHostVersion = ''

  # Минимальный номер версии Microsoft .NET Framework, необходимой для данного модуля. Это обязательное требование действительно только для выпуска PowerShell, предназначенного для компьютеров.
  # DotNetFrameworkVersion = ''

  # Минимальный номер версии среды CLR (общеязыковой среды выполнения), необходимой для работы данного модуля. Это обязательное требование действительно только для выпуска PowerShell, предназначенного для компьютеров.
  # CLRVersion = ''

  # Архитектура процессора (нет, X86, AMD64), необходимая для этого модуля
  # ProcessorArchitecture = ''

  # Модули, которые необходимо импортировать в глобальную среду перед импортированием данного модуля
  # RequiredModules = @()

  # Сборки, которые должны быть загружены перед импортированием данного модуля
  # RequiredAssemblies = @()

  # Файлы сценария (PS1), которые запускаются в среде вызывающей стороны перед импортом данного модуля.
  # ScriptsToProcess = @()

  # Файлы типа (.ps1xml), которые загружаются при импорте данного модуля
  # TypesToProcess = @()

  # Файлы формата (PS1XML-файлы), которые загружаются при импорте данного модуля
  # FormatsToProcess = @()

  # Модули для импорта в качестве вложенных модулей модуля, указанного в параметре RootModule/ModuleToProcess
  NestedModules     = @(
    'Scripts/CoreFunctions.ps1',
    'Scripts/Projects.ps1',
    'Scripts/Branches.ps1',
    'Scripts/Users.ps1',
    'Scripts/Issues.ps1',
    'Scripts//MergeRequest.ps1'
    'Scripts/Environments.ps1'
  )

  # В целях обеспечения оптимальной производительности функции для экспорта из этого модуля не используют подстановочные знаки и не удаляют запись. Используйте пустой массив, если нет функций для экспорта.
  FunctionsToExport = @(
    'Get-Encoded',
    'Get-GitlabItemsCount',
    'Get-GitlabItems',
    'Get-GitlabAllSubItems',
    'Get-GitlabSubItems',
    'Get-GitlabSubSubItems',
    'Set-GitlabApiUrl',
    'Set-Token',
    'Test-GitCmdEnvPath',
    'Find-GitlabItems',
    'Push-GitlabSubItemsAction',
    'Get-GitlabProject',
    'Set-GitlabProjectVisibility',
    'Get-GitlabCurrentProject',
    'CheckOut-GitlabBranch',
    'Get-GitlabUser',
    'Get-GitlabSSHKey',
    'Get-GitlabGPGKey',
    'Get-GitlabUserActivities',
    'Get-GitlabAllEnvironments',
    'Get-GitlabAvailableEnvironments',
    'Get-GitlabStoppedEnvironments',
    'Stop-GitlabEnvironment',
    'Get-GitlabIssues',
    'Get-GitlabIssueRelatedMRs',
    'Get-GitlabIssueClosedByMRs',
    'Get-GitlabMergeRequests',
    'Get-GitlabMergeRequestNotes',
    'Push-NewGitlabIssue'
  )

  # В целях обеспечения оптимальной производительности командлеты для экспорта из этого модуля не используют подстановочные знаки и не удаляют запись. Используйте пустой массив, если нет командлетов для экспорта.
  CmdletsToExport   = @()

  # Переменные для экспорта из данного модуля
  VariablesToExport = '*'

  # В целях обеспечения оптимальной производительности псевдонимы для экспорта из этого модуля не используют подстановочные знаки и не удаляют запись. Используйте пустой массив, если нет псевдонимов для экспорта.
  AliasesToExport   = @()

  # Ресурсы DSC для экспорта из этого модуля
  # DscResourcesToExport = @()

  # Список всех модулей, входящих в пакет данного модуля
  # ModuleList = @()

  # Список всех файлов, входящих в пакет данного модуля
  # FileList = @()

  # Личные данные для передачи в модуль, указанный в параметре RootModule/ModuleToProcess. Он также может содержать хэш-таблицу PSData с дополнительными метаданными модуля, которые используются в PowerShell.
  PrivateData       = @{

    PSData = @{

      # Теги, применимые к этому модулю. Они помогают с обнаружением модуля в онлайн-коллекциях.
      # Tags = @()

      # URL-адрес лицензии для этого модуля.
      # LicenseUri = ''

      # URL-адрес главного веб-сайта для этого проекта.
      # ProjectUri = ''

      # URL-адрес значка, который представляет этот модуль.
      # IconUri = ''

      # Заметки о выпуске этого модуля
      # ReleaseNotes = ''

    } # Конец хэш-таблицы PSData

  } # Конец хэш-таблицы PrivateData

  # Код URI для HelpInfo данного модуля
  # HelpInfoURI = ''

  # Префикс по умолчанию для команд, экспортированных из этого модуля. Переопределите префикс по умолчанию с помощью команды Import-Module -Prefix.
  # DefaultCommandPrefix = ''

}

