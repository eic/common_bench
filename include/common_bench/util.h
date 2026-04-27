#ifndef UTIL_H
#define UTIL_H

#include <cmath>
#include <exception>
#include <fmt/core.h>
#include <string>

#include <Math/Vector4D.h>

namespace common_bench {

/** Exception definition for unknown particle errors.
 */
class unknown_particle_error : public std::exception {
public:
  unknown_particle_error(std::string_view particle)
      : m_particle{particle},
        m_msg(fmt::format("Unknown particle type: {}", m_particle)) {}
  virtual const char *what() const throw() {
    return m_msg.c_str();
  }
  virtual const char *type() const throw() { return "unknown_particle_error"; }

private:
  const std::string m_particle;
  const std::string m_msg;
};

/** Simple function for pdg masses.
 *  Return the appropriate PDG mass for a small set of EIC-relevant particles.
 */
inline double get_pdg_mass(std::string_view part) {
  if (part == "electron") {
    return 0.0005109989461;
  } else if (part == "muon") {
    return .1056583745;
  } else if (part == "jpsi") {
    return 3.0969;
  } else if (part == "upsilon") {
    return 9.49630;
  } else if (part == "proton") {
    return 0.938272;
  } else {
    throw unknown_particle_error{part};
  }
}

/**  Find the decay lepton pair.
 *  Find the decay pair candidates from a vector of particles (parts),
 *  with invariant mass closest to a desired value (pdg_mass).
 */
inline std::pair<ROOT::Math::PxPyPzMVector, ROOT::Math::PxPyPzMVector>
find_decay_pair(const std::vector<ROOT::Math::PxPyPzMVector> &parts,
                const double pdg_mass, const double daughter_mass) {
  int first = -1;
  int second = -1;
  double best_mass = -1;

  for (size_t i = 0; i < parts.size(); ++i) {
    if (fabs(parts[i].mass() - daughter_mass) / daughter_mass > 0.01)
      continue;
    for (size_t j = i + 1; j < parts.size(); ++j) {
      if (fabs(parts[j].mass() - daughter_mass) / daughter_mass > 0.01)
        continue;
      const double new_mass{(parts[i] + parts[j]).mass()};
      if (fabs(new_mass - pdg_mass) < fabs(best_mass - pdg_mass)) {
        first = i;
        second = j;
        best_mass = new_mass;
      }
    }
  }
  if (first < 0) {
    return {{}, {}};
  }
  return {parts[first], parts[second]};
}

} // namespace common_bench

#endif
