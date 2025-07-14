import { ApiController } from './api_controller.js';
import { AppConstants } from '../constants/constants.js';
class CategoriesController {
    /**
     * Récupère la liste des catégories depuis l'API
     * @returns {Promise<Array>} Liste des catégories
     */
    static async fetchCategories() {
        try {
            const response = await fetch(
                `${AppConstants.BASE_URL}${AppConstants.CATEGORIE_URI}list/`, 
                {
                    method: 'GET',
                    headers: await ApiController.getHeaders()
                }
            );

            return await ApiController.processResponse(response);
        } catch (error) {
            console.log('URL appelée:', `${AppConstants.BASE_URL}${AppConstants.CATEGORIE_URI}list/`);
            console.error('Erreur dans CategoriesService:', error);
            throw error;
        }
    }

    /**
     * Affiche les catégories dans la console (pour debug)
     */
    static async logCategories() {
        try {
            const categories = await this.fetchCategories();
            
            if (categories?.length > 0) {
                console.table(categories.map(cat => ({
                    ID: cat.id,
                    Nom: cat.name,
                    Description: cat.description,
                    Créé: new Date(cat.created_at).toLocaleDateString()
                })));
            } else {
                console.log('Aucune catégorie trouvée');
            }
        } catch (error) {
            console.error('Erreur:', error.message);
        }
    }
}

// Exemple d'utilisation
(async () => {
    try {
        const categories = await CategoriesController.fetchCategories();
        console.log('Catégories chargées:', categories);
        
        // Ou pour un affichage formaté :
        await CategoriesController.logCategories();
    } catch (error) {
        // Gestion d'erreur dans l'UI
        document.getElementById('error-message').textContent = error.message;
    }
})();

export { CategoriesController };