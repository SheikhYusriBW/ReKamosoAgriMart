export default function FarmerDetailPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <h1>Farmer Detail: {params.id}</h1>
    </div>
  );
}
