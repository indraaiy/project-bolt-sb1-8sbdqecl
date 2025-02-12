import { useState } from "react";
import stripePromise from "../stripeClient";

function CheckoutButton() {
  const [loading, setLoading] = useState(false);

  async function handleCheckout() {
    setLoading(true);
    const stripe = await stripePromise;

    // Stuur een aanvraag naar je backend om een checkout sessie te maken
    const response = await fetch("http://localhost:5000/create-checkout-session", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
    });

    const session = await response.json();

    // Stuur gebruiker naar Stripe Checkout
    stripe?.redirectToCheckout({ sessionId: session.id });
  }

  return (
    <button onClick={handleCheckout} disabled={loading} className="bg-blue-600 text-white px-4 py-2 rounded">
      {loading ? "Laden..." : "Betaal met Stripe"}
    </button>
  );
}

export default CheckoutButton;
