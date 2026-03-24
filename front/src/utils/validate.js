const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PHONE_REGEX = /^(?:(?:\+|00)33[\s.-]?|0)[1-9](?:[\s.-]?\d{2}){4}$/;
const POSTAL_REGEX = /^\d{5}$/;

export const rules = {
  required: (label) => (v) =>
    v === '' || v === null || v === undefined ? `${label} est obligatoire` : null,

  email: (v) =>
    v && !EMAIL_REGEX.test(v) ? 'Adresse email invalide' : null,

  phone: (v) =>
    v && !PHONE_REGEX.test(v.replace(/\s/g, ''))
      ? 'Numéro de téléphone invalide (ex : 06 12 34 56 78)'
      : null,

  postalCode: (v) =>
    v && !POSTAL_REGEX.test(v) ? 'Code postal invalide (5 chiffres)' : null,

  positiveNumber: (label) => (v) =>
    v !== '' && v !== null && Number(v) <= 0 ? `${label} doit être supérieur à 0` : null,

  nonNegativeNumber: (label) => (v) =>
    v !== '' && v !== null && Number(v) < 0 ? `${label} ne peut pas être négatif` : null,

  year: (v) => {
    if (!v) return null;
    const n = Number(v);
    if (!Number.isInteger(n) || n < 1800 || n > new Date().getFullYear() + 2)
      return `Année invalide (entre 1800 et ${new Date().getFullYear() + 2})`;
    return null;
  },
};

/**
 * Valide un objet form selon un schéma { champ: [règle, règle, ...] }
 * Retourne un objet { champ: "message d'erreur" } — vide si tout est OK.
 */
export function validate(form, schema) {
  const errors = {};
  for (const [field, fieldRules] of Object.entries(schema)) {
    for (const rule of fieldRules) {
      const msg = rule(form[field]);
      if (msg) { errors[field] = msg; break; }
    }
  }
  return errors;
}

export const hasErrors = (errors) => Object.keys(errors).length > 0;
