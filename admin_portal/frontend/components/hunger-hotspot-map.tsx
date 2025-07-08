import { useEffect, useRef, useState } from "react";
import maplibregl from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

export function HungerHotspotMap() {
    const mapRef = useRef<HTMLDivElement | null>(null);
    const mapInstance = useRef<maplibregl.Map | null>(null);

    const [searchLat, setSearchLat] = useState("");
    const [searchLng, setSearchLng] = useState("");

    const chennaiCoords: [number, number] = [80.2707, 13.0827]; // Chennai city center

    useEffect(() => {
        if (!mapRef.current || mapInstance.current) return;

        const map = new maplibregl.Map({
            container: mapRef.current,
            style: "https://api.maptiler.com/maps/streets/style.json?key=TVEiZHGfdUoMSA60atci",
            center: chennaiCoords,
            zoom: 12,
        });

        mapInstance.current = map;

        // Hunger Spot Marker: Tondiarpet
        new maplibregl.Marker({ color: "#f43f5e" }) // red marker
            .setLngLat([80.294, 13.1325])
            .setPopup(
                new maplibregl.Popup({ offset: 25 }).setHTML(
                    `<strong>Name:</strong> Tondiarpet<br/><strong>People:</strong> 60`
                )
            )
            .addTo(map);
        new maplibregl.Marker({ color: "#f43f5e" }) // red marker
            .setLngLat([80.2482, 13.0872])
            .setPopup(
                new maplibregl.Popup({ offset: 25 }).setHTML(
                    `<strong>Name:</strong> Otteri<br/><strong>People:</strong> 25`
                )
            )
            .addTo(map);
    }, []);

    // Handle search
    const handleSearch = () => {
        const lat = parseFloat(searchLat);
        const lng = parseFloat(searchLng);
        if (!isNaN(lat) && !isNaN(lng) && mapInstance.current) {
            mapInstance.current.flyTo({ center: [lng, lat], zoom: 14 });
        }
    };

    // Reset to Chennai view
    const handleReset = () => {
        if (mapInstance.current) {
            mapInstance.current.flyTo({ center: chennaiCoords, zoom: 12 });
        }
    };

    return (
        <Card>
            <CardHeader>
                <CardTitle>Hunger Hotspot Map</CardTitle>
                <CardDescription>Search and view key hunger locations in the city.</CardDescription>
            </CardHeader>
            <CardContent>
                <div className="mb-4 flex gap-2">
                    <Input
                        placeholder="Latitude"
                        value={searchLat}
                        onChange={(e) => setSearchLat(e.target.value)}
                        className="w-1/3"
                    />
                    <Input
                        placeholder="Longitude"
                        value={searchLng}
                        onChange={(e) => setSearchLng(e.target.value)}
                        className="w-1/3"
                    />
                    <Button onClick={handleSearch}>Go</Button>
                    <Button variant="outline" onClick={handleReset}>
                        Reset View
                    </Button>
                </div>
                <div className="h-96 w-full rounded-md overflow-hidden">
                    <div ref={mapRef} className="h-full w-full z-0" />
                </div>
            </CardContent>
        </Card>
    );
}
