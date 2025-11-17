# Claude Code Notifications for macOS

Sistema de notificações para macOS integrado com Claude Code. Envia notificações para a Central de Notificações do macOS, sincronizando automaticamente com iPhone, iPad e outros dispositivos via iCloud.

## Sumário

- [Instalação](#instalação)
- [Uso Básico](#uso-básico)
- [Tipos de Notificações](#tipos-de-notificações)
- [Opções Disponíveis](#opções-disponíveis)
- [Aliases Disponíveis](#aliases-disponíveis)
- [Exemplos de Uso](#exemplos-de-uso)
- [Integração com Claude Code](#integração-com-claude-code)
- [Configuração do macOS](#configuração-do-macos)
- [Logs](#logs)
- [Solução de Problemas](#solução-de-problemas)
- [Boas Práticas](#boas-práticas)

---

## Instalação

### 1. Tornar o Script Executável

O script já está configurado como executável. Caso precise reconfigurar:

```bash
chmod +x /Users/andersonlimadev/Projects/lemon_scripts/notifications/notifications_claude_code.sh
```

### 2. Recarregar o .zshrc

Para ativar os aliases no terminal atual:

```bash
source ~/.zshrc
```

Ou simplesmente abra um novo terminal.

### 3. Verificar Instalação

```bash
claude-notify --version
# ou
cn --help
```

---

## Uso Básico

### Comando Principal

```bash
claude-notify "Sua mensagem aqui"
# ou usando o alias curto
cn "Sua mensagem aqui"
```

### Sintaxe Completa

```bash
claude-notify [OPÇÕES] <mensagem>
```

---

## Tipos de Notificações

O sistema suporta 5 tipos de notificações, cada um com visual e comportamento específico:

| Tipo | Flag | Emoji | Descrição |
|------|------|-------|-----------|
| **info** | `-T info` | ℹ️ | Informações gerais |
| **success** | `-T success` | ✅ | Operações bem-sucedidas |
| **warning** | `-T warning` | ⚠️ | Alertas e avisos |
| **error** | `-T error` | ❌ | Erros e falhas |
| **important** | `-i` ou `-T important` | 🔴 | Notificações críticas |

---

## Opções Disponíveis

### Opções Básicas

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-h, --help` | Exibe ajuda completa | `cn --help` |
| `-v, --version` | Exibe versão do script | `cn --version` |
| `-t, --title <texto>` | Define título personalizado | `cn -t "Build" "Concluído"` |
| `-s, --subtitle <texto>` | Define subtítulo | `cn -s "v2.0.0" "Deployed"` |
| `-T, --type <tipo>` | Define tipo de notificação | `cn -T success "OK"` |

### Opções Avançadas

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-S, --sound <som>` | Define som personalizado | `cn -S Glass "Done"` |
| `-i, --important` | Marca como importante | `cn -i "Urgente!"` |
| `-r, --summary` | Adiciona ao resumo | `cn -r "Task done"` |
| `-q, --quiet` | Sem output no terminal | `cn -q "Silent"` |
| `-l, --log` | Salva em arquivo de log | `cn -l "Logged"` |
| `--no-sound` | Desativa som | `cn --no-sound "Quiet"` |
| `--list-sounds` | Lista sons disponíveis | `cn --list-sounds` |

---

## Aliases Disponíveis

### Comandos Principais

```bash
claude-notify        # Comando completo
cn                   # Alias curto principal
```

### Atalhos por Tipo

```bash
cn-success <msg>     # Notificação de sucesso
cn-error <msg>       # Notificação de erro
cn-warning <msg>     # Notificação de aviso
cn-info <msg>        # Notificação informativa
cn-important <msg>   # Notificação crítica/importante
```

### Notificações Pré-definidas

```bash
cn-build-ok          # "Build completed successfully"
cn-build-fail        # "Build failed"
cn-tests-ok          # "All tests passed"
cn-tests-fail        # "Tests failed"
cn-deploy-ok         # "Deployment successful"
cn-task-done         # "Task completed"
```

### Ajuda

```bash
claude-notify-help   # Lista todos os aliases disponíveis
```

---

## Exemplos de Uso

### Notificações Simples

```bash
# Notificação básica
cn "Hello World"

# Com tipo específico
cn-success "Operação concluída"
cn-error "Falha na conexão"
cn-warning "Disco quase cheio"
```

### Notificações Personalizadas

```bash
# Título e subtítulo personalizados
cn -t "Git" -s "main branch" "Push realizado com sucesso"

# Notificação importante sem som
cn -i --no-sound "Atenção: atualização pendente"

# Com log habilitado
cn -l -T success "Deploy concluído às $(date '+%H:%M')"
```

### Encadeamento com Comandos

```bash
# Notificar resultado de build
npm run build && cn-build-ok || cn-build-fail

# Notificar resultado de testes
npm test && cn-tests-ok || cn-tests-fail

# Git push com notificação
git push origin main && cn -t "Git" -T success "Código enviado"

# Instalação de dependências
npm install && cn-success "Dependências instaladas"
```

### Notificações Silenciosas

```bash
# Para scripts em background
cn -q "Processo finalizado"

# Para cron jobs
0 * * * * /path/to/script.sh && cn -q -l "Tarefa horária concluída"
```

---

## Integração com Claude Code

### Após Builds

```bash
# Em package.json scripts
{
  "scripts": {
    "build": "webpack && cn-build-ok || cn-build-fail",
    "test": "jest && cn-tests-ok || cn-tests-fail"
  }
}
```

### Após Operações Git

```bash
# Commit e push
git add . && git commit -m "feat: nova feature" && git push && cn -t "Git" -T success "Commit e push realizados"

# Pull request criado
gh pr create --title "Feature X" --body "..." && cn-important "Pull Request criado"
```

### Em Scripts de CI/CD

```bash
#!/bin/bash
# deploy.sh
echo "Iniciando deploy..."
cn -t "Deploy" -T info "Iniciando processo de deploy"

# ... comandos de deploy ...

if [ $? -eq 0 ]; then
    cn -t "Deploy" -T success "Deploy concluído com sucesso!"
else
    cn -t "Deploy" -T error "Falha no deploy!"
fi
```

### Com Claude Code CLI

```bash
# Após Claude Code completar uma tarefa
claude "Implemente feature X" && cn-task-done

# Notificar quando Claude terminar
claude "Corrija o bug no auth.js" && cn -i "Claude Code finalizou a correção"
```

---

## Configuração do macOS

### Permitir Notificações

Para que as notificações funcionem corretamente:

1. Abra **Preferências do Sistema** > **Notificações e Foco**
2. Encontre **Terminal** (ou **iTerm** se usar)
3. Ative **Permitir Notificações**
4. Configure:
   - **Estilo de Alerta**: Alertas ou Banners
   - **Mostrar na Tela Bloqueada**: Ativado
   - **Mostrar no Centro de Notificações**: Ativado
   - **Reproduzir som para notificações**: Ativado

### Sincronização com iCloud

As notificações sincronizam automaticamente com:
- iPhone
- iPad
- Apple Watch
- Outros Macs

Certifique-se de que todos os dispositivos estejam:
- Conectados à mesma conta iCloud
- Com **Notificações** habilitadas em **Configurações** > **iCloud**

---

## Logs

### Localização

O arquivo de log fica em:
```
~/.claude_notifications.log
```

### Formato do Log

```
[2025-11-16 14:30:45] [SUCCESS] Title: Claude Code | Subtitle:  | Message: Build completed
```

### Habilitar Logging

```bash
cn -l "Mensagem com log"
```

### Visualizar Logs

```bash
# Ver últimas entradas
tail -20 ~/.claude_notifications.log

# Monitorar em tempo real
tail -f ~/.claude_notifications.log

# Buscar por tipo
grep "ERROR" ~/.claude_notifications.log
```

### Limpar Logs

```bash
> ~/.claude_notifications.log
```

---

## Solução de Problemas

### Notificação não aparece

1. **Verifique permissões do Terminal**:
   ```bash
   # Abra Preferências do Sistema > Notificações
   # Ative notificações para Terminal/iTerm
   ```

2. **Verifique se o script é executável**:
   ```bash
   ls -la /Users/andersonlimadev/Projects/lemon_scripts/notifications/notifications_claude_code.sh
   # Deve mostrar -rwxr-xr-x
   ```

3. **Teste o AppleScript diretamente**:
   ```bash
   osascript -e 'display notification "Test" with title "Test"'
   ```

### Aliases não funcionam

1. **Recarregue o .zshrc**:
   ```bash
   source ~/.zshrc
   ```

2. **Verifique se foi adicionado**:
   ```bash
   grep "claude-notify" ~/.zshrc
   ```

3. **Abra um novo terminal**

### Erro de permissão

```bash
# Não precisa de sudo!
chmod +x /path/to/notifications_claude_code.sh
```

### Som não toca

1. **Liste sons disponíveis**:
   ```bash
   cn --list-sounds
   ```

2. **Teste com som específico**:
   ```bash
   cn -S Glass "Test"
   ```

### Caracteres estranhos no terminal

Verifique se seu terminal suporta UTF-8:
```bash
echo $LANG
# Deve ser algo como: en_US.UTF-8
```

---

## Boas Práticas

### 1. Use Tipos Apropriados

```bash
# BOM: Tipo correto para a situação
cn-error "Build falhou: erro de sintaxe"

# RUIM: Tipo genérico
cn "Build falhou: erro de sintaxe"
```

### 2. Mensagens Concisas

```bash
# BOM: Direto ao ponto
cn-success "Deploy v2.0.0 concluído"

# RUIM: Muito longo
cn "O processo de deployment da versão 2.0.0 foi finalizado com sucesso no ambiente de produção"
```

### 3. Use Títulos Contextuais

```bash
# BOM: Contexto claro
cn -t "Database" -T success "Migration concluída"

# RUIM: Sem contexto
cn "Migration concluída"
```

### 4. Habilite Logs para Tarefas Críticas

```bash
# Para tarefas importantes, sempre log
cn -l -T important "Backup do banco iniciado"
```

### 5. Encadeie com Operações

```bash
# Sempre notifique o resultado
comando && cn-success "OK" || cn-error "Falhou"
```

### 6. Notificações Silenciosas para Automação

```bash
# Em scripts automatizados
cn -q -l "Tarefa automatizada concluída"
```

### 7. Evite Spam de Notificações

```bash
# Em loops, agrupe notificações
count=0
for file in *.js; do
    process_file "$file"
    ((count++))
done
cn-success "Processados $count arquivos"
```

---

## Estrutura do Projeto

```
/Users/andersonlimadev/Projects/lemon_scripts/notifications/
├── notifications_claude_code.sh       # Script principal
└── notifications_claude_code.readme.md  # Esta documentação
```

---

## Contribuição e Suporte

### Modificando o Script

O script está localizado em:
```
/Users/andersonlimadev/Projects/lemon_scripts/notifications/notifications_claude_code.sh
```

### Backup do .zshrc

Antes de modificar:
```bash
cp ~/.zshrc ~/.zshrc.backup
```

### Restaurar .zshrc

```bash
cp ~/.zshrc.backup ~/.zshrc
source ~/.zshrc
```

---

## Versão

- **Versão**: 1.0.0
- **Autor**: @anderson.lima.dev
- **Data**: 2025-11-16
- **Licença**: MIT

---

## Changelog

### v1.0.0 (2025-11-16)
- Implementação inicial
- Suporte a 5 tipos de notificação
- Integração com macOS Notification Center
- Aliases para .zshrc
- Sistema de logging
- Documentação completa
