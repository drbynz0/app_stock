import { ProductsController } from '../controllers/products_controller.js';

class ProductsService {
    /**
     * Charge et affiche les catégories dans le DOM
     */
    static async loadProducts() {
        const productsSection = document.querySelector('.product-listing .product-grid');
        
        if (!productsSection) {
            console.error('Section des produits introuvable dans le DOM');
            return;
        }

        // Afficher un loader pendant le chargement
        productsSection.innerHTML = `
            <div class="loading-spinner">
                <div class="spinner"></div>
                <p>Chargement des produits...</p>
            </div>
        `;

        try {
            const products = await ProductsController.fetchProducts();
            
            if (products && products.length > 0) {
                productsSection.innerHTML = products.map(product => `
                    <div class="product-card" data-product-id="${product.id}">
                        <div class="product-badge">Nouveau</div>
                        <div class="product-image">
                            <img src="${product.images && product.images.length > 0 ? product.images[0].image : 'https://img.freepik.com/premium-photo/flat-shopping-bag-with-percentage-sign-vector-concept-as-vector-shopping-bag-with-percentage_980716-664374.jpg?w=2000'}" alt="${product.name}">
                            <div class="quick-view">Voir détails</div>
                        </div>
                        <div class="product-info">
                            <h3>${product.name}</h3>
                            <div class="product-meta">
                                <span class="rating">
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star-half-alt"></i>
                                    <span>(24)</span>
                                </span>
                            </div>
                            <div class="price">€599.99 <span class="old-price">${product.price}</span></div>
                            <button class="add-to-cart">Ajouter au panier</button>
                        </div>
                    </div>
                `).join('');
            } else {
                productsSection.innerHTML = '<p class="no-categories">Aucun produit disponible pour le moment.</p>';
            }
        } catch (error) {
            console.error('Erreur lors du chargement des produits:', error);
            productsSection.innerHTML = `
                <p class="error-message">
                    Erreur lors du chargement des produits. 
                    <button onclick="ProductsService.loadProducts()">Réessayer</button>
                </p>
            `;
        }
    }

}

// Charge les produits au chargement de la page
document.addEventListener('DOMContentLoaded', () => {
    ProductsService.loadProducts();
});

// Rend la méthode disponible globalement pour le bouton "Réessayer"
window.ProductsService = ProductsService;

export { ProductsService };