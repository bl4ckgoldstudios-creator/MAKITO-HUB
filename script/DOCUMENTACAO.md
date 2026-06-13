# MAKITO HUB PRO - V11.0
## Documentação Oficial e Guia Completo de Uso

---

## 📋 Índice
1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Requisitos e Compatibilidade](#2-requisitos-e-compatibilidade)
3. [Guia de Instalação](#3-guia-de-instalação)
4. [Funcionalidades Principais](#4-funcionalidades-principais)
5. [Sistema de Segurança](#5-sistema-de-segurança)
6. [Atualizações Automáticas](#6-atualizações-automáticas)
7. [Dicas de Uso e Otimização](#7-dicas-de-uso-e-otimização)
8. [Guia de Troubleshooting](#8-guia-de-troubleshooting)

---

## 1. Visão Geral do Projeto

**MAKITO HUB PRO V11.0** é o script de Blox Fruits mais completo e seguro disponível. Projetado por **BLACK GOLD STUDIOS**, ele combina todas as funcionalidades essenciais em um framework modular, de alto desempenho e com segurança avançada.

### Principais Características:
- ✅ **Modularidade:** Estrutura organizada em módulos individuais para fácil manutenção
- ✅ **Segurança Avançada:** Anti-cheat detection, modo stealth e logs criptografados
- ✅ **Auto-Update:** Atualizações automáticas para acompanhar as versões do Blox Fruits
- ✅ **Persistência:** Configurações salvas e carregadas automaticamente
- ✅ **Atalhos:** Sistema de keybinds personalizável
- ✅ **UI Amigável:** Interface intuitiva para mobile e PC

---

## 2. Requisitos e Compatibilidade

### Compatibilidade com Executores:
✅ **Synapse X**  
✅ **Script-Ware**  
✅ **KRNL** (com suporte a `readfile/writefile`)  
✅ **Electron**  
✅ **Celery**  

### Requisitos do Sistema:
- Windows 10/11
- Roblox Client (versão oficial)
- Pelo menos 4GB de RAM (8GB recomendado para multi-contas)

---

## 3. Guia de Instalação

### Passo 1: Preparar a Estrutura de Pastas
1. Abra o executor de scripts de sua preferência
2. Localize a pasta de trabalho do executor (geralmente `workspace/` ou `scripts/`)
3. Copie todos os arquivos para a estrutura abaixo:

```
📁 workspace/
├── 📄 main.lua
└── 📁 modules/
    ├── 📄 Combat.lua
    ├── 📄 Data.lua
    ├── 📄 Farming.lua
    ├── 📄 Loader.lua
    ├── 📄 Security.lua (NOVO!)
    ├── 📄 Settings.lua
    ├── 📄 Updater.lua (NOVO!)
    ├── 📄 UI.lua
    └── 📄 Utils.lua
```

### Passo 2: Executar o Script
1. No executor, selecione e execute o arquivo **`main.lua`**
2. Aguardar até que o console (F9) confirme o carregamento completo
3. A interface gráfica (UI) aparecerá na tela

**Verificação de Carregamento:**
Confira no console (F9) as mensagens:
```
✅ [MAKITO] Configurações carregadas!
✅ Módulo carregado: Settings
✅ Módulo carregado: Data
✅ Módulo carregado: Utils
✅ Módulo carregado: Combat
✅ Módulo carregado: Farming
✅ Módulo carregado: UI
✅ Módulo carregado: Security (NOVO!)
✅ Módulo carregado: Updater (NOVO!)
🚀 [MAKITO HUB PRO] V11.0 Inicializado com sucesso!
```

---

## 4. Funcionalidades Principais

### 4.1 Automação de Farming (Auto Farm)
- **Auto Quest:** Completa automaticamente missões dos NPCs
- **Auto Farm Level:** Ataque mobs em ordem de nível ideal
- **Bring Mobs:** Traz inimigos para a sua posição (Black Hole)
- **Auto Bone Farm:** Farm de ossos no Haunted Castle (Sea 3)
- **Auto Materials:** Farm de materiais específicos (Dragon Scale, Iron, etc.)

### 4.2 Boss e Raids
- **Auto Boss:** Farm de bosses globais e locais
- **Auto Raid:** Raids completas com sucesso garantido
- **Auto Buy Chip:** Compra automaticamente fragmentos de raid
- **Modo Raid:** Selecione "Above" ou "Inside" para posicionamento ideal

### 4.3 Sea Events (Eventos de Mar)
- **Auto Kitsune Event:** Detecção e coleta de Azure Embers
- **Auto Leviathan:** Farm do Leviathan
- **Auto Terror Shark:** Farm do Terror Shark
- **Mirage Island:** Esp e teleporte para a ilha mirage
- **Find Blue Gear:** Localiza a engrenagem azul automaticamente

### 4.4 Frutas e Mastery
- **Auto Fruit Finder:** Esp de frutas espalhadas pelo mapa
- **Auto Collect Fruit:** Coleta frutas automaticamente
- **Auto Store Fruit:** Armazena frutas no inventário
- **Auto Mastery:** Aumenta mastery de habilidades automaticamente
- **Auto Roll Race:** Troca de raça até encontrar a desejada

### 4.5 ESP e Visual
- **Full Bright:** Iluminação máxima do mapa
- **FPS Boost:** Melhoria de desempenho
- **White Screen:** Desativa renderização 3D para economizar recursos (ideal para farms longos)
- **Rainbow UI:** Tema dinâmico para a interface
- **ESP Customizável:** Cor e estilo dos objetos visíveis

---

## 5. Sistema de Segurança (NOVO!)

O MAKITO HUB PRO V11.0 implementa um sistema de segurança de nível profissional:

### 5.1 Modo Stealth
Habilitado por padrão (`Settings.StealthSecurity = true`):
- Oculta logs suspeitos
- Evita padrões de comportamento detectáveis
- Hook seguro de funções exploit

### 5.2 Logs Criptografados
Todas as atividades são armazenadas em `makito_encrypted_logs.txt`, criptografadas para evitar detecção.

### 5.3 Humanização
- Randomiza intervalos de ações para simular comportamento humano
- Evita padrões de clique e movimento repetitivos
- `HumanDelayMin` e `HumanDelayMax` configuráveis (0.2 a 1.8 segundos)

---

## 6. Atualizações Automáticas (NOVO!)

### Funcionamento Básico:
1. O script verifica automaticamente por atualizações ao inicializar
2. Caso uma nova versão esteja disponível, você é notificado
3. As atualizações são aplicadas automaticamente (se `AutoUpdateEnabled = true`)

### Configuração do Repositório:
Edite o arquivo `modules/Updater.lua` para definir o seu repositório de atualizações:
```lua
local UPDATE_BASE_URL = "https://raw.githubusercontent.com/SEU-USERNAME/MAKITO-HUB/main"
```

---

## 7. Dicas de Uso e Otimização

### Dicas de Segurança:
1. **Não use Rage Mode em público:** O `StealthMode` deve estar sempre ativado em servers cheios
2. **Alternar servidores periodicamente:** Evite farm por mais de 2 horas consecutivas no mesmo servidor
3. **Use contas secundárias:** Primeiro teste novas funcionalidades em contas "sacrifício"

### Dicas de Desempenho:
1. **FPS Boost + White Screen:** Para farms longos, ative as duas opções para economizar recursos
2. **Auto Farm em servidores vazios:** Menos chance de lag e detecção
3. **Limite o raio de Kill Aura:** `KillAuraDistance` em até 100 para evitar bans

### Keybinds Padrão (Atalhos):
| Atalho | Função |
|--------|--------|
| **Right Control (Ctrl Direito)** | Abrir/Fechar o Hub |
| **K** | Ligar/Desligar Kill Aura |
| **F** | Ligar/Desligar Auto Farm |
| **E** | Ligar/Desligar ESP |

Para alterar os keybinds, edite o arquivo `modules/Settings.lua` na seção `Keybinds`.

---

## 8. Guia de Troubleshooting

### Problema 1: "Falha ao carregar módulos"
**Solução:**
- Verifique a estrutura de pastas (ela deve estar exatamente como na seção 3)
- Certifique-se de que todos os arquivos `.lua` estão presentes e não corrompidos
- Tente usar um executor diferente (Synapse X é recomendado para compatibilidade máxima)

### Problema 2: "Nada acontece ao executar o script"
**Solução:**
- Pressione **F9** para abrir o console de debug e verificar erros
- Confira se o seu executor suporta as funções `readfile` e `writefile`
- Tente executar o script após o jogo ter carregado completamente

### Problema 3: "UI está pequena ou desalinhada"
**Solução:**
- Ajuste a escala da UI em `Settings` → `UIScale`
- Tente valores como `0.8`, `1.0` ou `1.2`

### Problema 4: "Configs não estão sendo salvas"
**Solução:**
- Certifique-se de que o seu executor tem permissão para gravar arquivos na pasta `workspace`
- Tente rodar o executor como Administrador

---

## 9. Estrutura de Arquivos (Referência para Desenvolvedores)

```
main.lua                    # Arquivo principal de inicialização
DOCUMENTACAO.md             # Este arquivo
modules/
├── Settings.lua            # Gerencia configurações e persistência
├── Data.lua                # Dados do jogo (CFrames, quests, etc.)
├── Utils.lua               # Funções utilitárias (ESP, cache, etc.)
├── Combat.lua              # Sistema de combate (Kill Aura, Fast Attack)
├── Farming.lua             # Automação de farm e quests
├── UI.lua                  # Interface gráfica do usuário
├── Security.lua            # [NOVO] Sistema de segurança e logs
├── Updater.lua             # [NOVO] Auto-update e versionamento
└── Loader.lua              # Carregador de módulos inteligente
```

### Criando Novos Módulos (Para Desenvolvedores)
1. Crie um arquivo `modules/SeuModulo.lua`
2. Implemente uma tabela com as funções:
```lua
local SeuModulo = {}

function SeuModulo.FuncaoExemplo()
    print("Olá mundo!")
end

return SeuModulo
```
3. Adicione `"SeuModulo"` à lista `modulesToLoad` no `main.lua`
4. Use no código como `Makito.SeuModulo.FuncaoExemplo()`

---

## 10. Aviso Legal e Isenção de Responsabilidade

⚠️ **Aviso Importante:**  
O uso de scripts em jogos online pode resultar em banimento permanente da conta. Este software é fornecido "como está", sem garantias de qualquer tipo. O desenvolvedor não se responsabiliza por quaisquer consequências do uso deste script.

Use por sua conta e risco!

---

## 11. Contato e Suporte

- **Versão Atual:** 11.0
- **Última Atualização:** Junho de 2026
- **Desenvolvedor:** LuaMasterX

Para dúvidas, sugestões ou problemas, consulte a seção de troubleshooting acima.

---

Divirta-se e farm com segurança! 🎮🚀
