import { ApiController } from './api_controller.js';
import { AppConstants } from '../constants/constants.js';
class ProductsController {
    /**
     * Récupère la liste des produits depuis l'API
     * @returns {Promise<Array>} Liste des produits
     */
    static async fetchProducts() {
        try {
            const response = await fetch(
                `${AppConstants.BASE_URL}${AppConstants.PRODUCT_URI}list/`, 
                {
                    method: 'GET',
                    headers: await ApiController.getHeaders()
                }
            );

            return await ApiController.processResponse(response);
        } catch (error) {
            console.log('URL appelée:', `${AppConstants.BASE_URL}${AppConstants.PRODUCT_URI}list/`);
            console.error('Erreur dans ProductsService:', error);
            throw error;
        }
    }

    /**
     * Affiche les catégories dans la console (pour debug)
     */
    static async logProducts() {
        try {
            const categories = await this.fetchProducts();
            
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
        const products = await ProductsController.fetchProducts();
        console.log('Catégories chargées:', products);
        
        // Ou pour un affichage formaté :
        await ProductsController.logProducts();
    } catch (error) {
        // Gestion d'erreur dans l'UI
        document.getElementById('error-message').textContent = error.message;
    }
})();

export { ProductsController };