#ifndef TYPELIB_EXPORT_TLB_HH
#define TYPELIB_EXPORT_TLB_HH

#include "exporter.hh"

class TlbExport : public Typelib::Exporter
{
protected:
    /** Called by save to add a prelude before saving all registry types */
    virtual bool begin(std::ostream& stream, Typelib::Registry const& registry);
    /** Called by save to add data after saving all registry types */
    virtual bool end  (std::ostream& stream, Typelib::Registry const& registry);

public:
    virtual bool save
        ( std::ostream& stream
        , Typelib::RegistryIterator const& type);
};

#endif
