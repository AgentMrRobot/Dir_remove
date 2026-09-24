#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  suppr_dossier.sh
#  Script interactif de suppression de dossier (Termux / Linux)
# ============================================================

# --- Couleurs pour l'affichage ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Variables globales ---
CHEMIN=""
AUTO_MODE=0   # 0 = confirmation demandée, 1 = suppression automatique sans confirmation

# --- Fonction : afficher l'en-tête ---
afficher_entete() {
    clear
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}   SCRIPT DE SUPPRESSION DE DOSSIER - MENU   ${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo -e "Chemin actuel : ${YELLOW}${CHEMIN:-<non défini>}${NC}"
    if [ "$AUTO_MODE" -eq 1 ]; then
        echo -e "Mode automatique : ${GREEN}ACTIVÉ (sans confirmation)${NC}"
    else
        echo -e "Mode automatique : ${RED}DÉSACTIVÉ (confirmation requise)${NC}"
    fi
    echo -e "${CYAN}============================================${NC}"
}

# --- Fonction : définir / changer le chemin ---
changer_chemin() {
    echo ""
    read -rp "Entrez le chemin complet du dossier à cibler : " nouveau_chemin

    # Expansion du ~ si utilisé
    nouveau_chemin="${nouveau_chemin/#\~/$HOME}"

    if [ -z "$nouveau_chemin" ]; then
        echo -e "${RED}Aucun chemin saisi.${NC}"
    else
        CHEMIN="$nouveau_chemin"
        echo -e "${GREEN}Chemin défini : $CHEMIN${NC}"
    fi
    read -rp "Appuyez sur Entrée pour continuer..." _
}

# --- Fonction : vérifier si le chemin existe et est un dossier ---
verifier_chemin() {
    if [ -z "$CHEMIN" ]; then
        echo -e "${RED}Erreur : aucun chemin défini. Utilisez l'option 1 d'abord.${NC}"
        return 1
    fi
    if [ ! -e "$CHEMIN" ]; then
        echo -e "${RED}Erreur : le chemin '$CHEMIN' n'existe pas.${NC}"
        return 1
    fi
    if [ ! -d "$CHEMIN" ]; then
        echo -e "${RED}Erreur : '$CHEMIN' n'est pas un dossier.${NC}"
        return 1
    fi
    return 0
}

# --- Fonction : lister le contenu du dossier ciblé ---
lister_contenu() {
    echo ""
    if verifier_chemin; then
        echo -e "${YELLOW}Contenu de $CHEMIN :${NC}"
        ls -lah "$CHEMIN"
    fi
    read -rp "Appuyez sur Entrée pour continuer..." _
}

# --- Fonction : suppression réelle ---
executer_suppression() {
    rm -rf -- "$CHEMIN"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Dossier '$CHEMIN' supprimé avec succès.${NC}"
        # log de l'opération
        echo "$(date '+%Y-%m-%d %H:%M:%S') - SUPPRIMÉ : $CHEMIN" >> "$HOME/.suppr_dossier.log"
    else
        echo -e "${RED}Échec de la suppression de '$CHEMIN'.${NC}"
    fi
}

# --- Fonction : suppression immédiate (avec ou sans confirmation selon AUTO_MODE) ---
suppression_immediate() {
    echo ""
    if ! verifier_chemin; then
        read -rp "Appuyez sur Entrée pour continuer..." _
        return
    fi

    if [ "$AUTO_MODE" -eq 1 ]; then
        echo -e "${YELLOW}Mode automatique actif : suppression sans confirmation...${NC}"
        executer_suppression
    else
        echo -e "${RED}ATTENTION : vous allez supprimer définitivement :${NC}"
        echo -e "${YELLOW}$CHEMIN${NC}"
        read -rp "Confirmer la suppression ? (oui/non) : " confirmation
        if [ "$confirmation" = "oui" ]; then
            executer_suppression
        else
            echo -e "${CYAN}Suppression annulée.${NC}"
        fi
    fi
    read -rp "Appuyez sur Entrée pour continuer..." _
}

# --- Fonction : activer / désactiver le mode automatique (autorisation) ---
basculer_mode_auto() {
    echo ""
    if [ "$AUTO_MODE" -eq 1 ]; then
        AUTO_MODE=0
        echo -e "${RED}Mode automatique désactivé.${NC} Une confirmation sera demandée à chaque suppression."
    else
        echo -e "${YELLOW}Le mode automatique supprime SANS demander de confirmation.${NC}"
        read -rp "Voulez-vous vraiment l'activer ? (oui/non) : " reponse
        if [ "$reponse" = "oui" ]; then
            AUTO_MODE=1
            echo -e "${GREEN}Mode automatique activé.${NC}"
        else
            echo -e "${CYAN}Mode automatique non modifié.${NC}"
        fi
    fi
    read -rp "Appuyez sur Entrée pour continuer..." _
}

# --- Menu principal ---
menu_principal() {
    while true; do
        afficher_entete
        echo "1) Définir / changer le chemin du dossier"
        echo "2) Lister le contenu du dossier ciblé"
        echo "3) Supprimer le dossier maintenant"
        echo "4) Activer / désactiver le mode automatique (autorisation)"
        echo "5) Quitter"
        echo ""
        read -rp "Choisissez une option [1-5] : " choix

        case "$choix" in
            1) changer_chemin ;;
            2) lister_contenu ;;
            3) suppression_immediate ;;
            4) basculer_mode_auto ;;
            5)
                echo -e "${CYAN}Fin du script.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Option invalide.${NC}"
                read -rp "Appuyez sur Entrée pour continuer..." _
                ;;
        esac
    done
}

# --- Point d'entrée ---
menu_principal

